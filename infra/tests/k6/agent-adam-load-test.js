// ─────────────────────────────────────────────────────────────────
// Agent Adam — k6 Load Test Suite
// SilverTech | June 2026
//
// Performance test scenarios:
//   1. Smoke test (baseline — 5 VUs for 1 min)
//   2. Average load (normal day — 50 VUs for 5 min)
//   3. Stress test (morning peak — 200 VUs ramping)
//   4. Voice WebSocket (concurrent calls — 20 VUs sustained)
//   5. SOS spike (emergency burst — 100 VUs in 30s)
//
// Run: k6 run --env SCENARIO=smoke agent-adam-load-test.js
//      k6 run --env SCENARIO=stress agent-adam-load-test.js
//      k6 run --env SCENARIO=voice agent-adam-load-test.js
//      k6 run --env SCENARIO=sos     agent-adam-load-test.js
//      k6 run --env SCENARIO=all     agent-adam-load-test.js
// ─────────────────────────────────────────────────────────────────

import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Counter, Rate, Trend, Gauge } from 'k6/metrics';
import { textSummary } from 'https://jslib.k6.io/k6-summary/0.0.1/index.js';
import { URL, URLSearchParams } from 'https://jslib.k6.io/url/1.0.0/index.js';

// ═══════════════════════════════════════════════════════════════
// CONFIGURATION
// ═══════════════════════════════════════════════════════════════

const BASE_URL = __ENV.BASE_URL || 'https://api.silvertech.ai';
const SCENARIO = __ENV.SCENARIO || 'smoke';
const TEST_SENIOR_ID = __ENV.SENIOR_ID || 'senior-001';
const AUTH_TOKEN = __ENV.AUTH_TOKEN || 'test-token';

// ═══════════════════════════════════════════════════════════════
// CUSTOM METRICS
// ═══════════════════════════════════════════════════════════════

const voiceCallsStarted = new Counter('voice_calls_started');
const voiceCallsCompleted = new Counter('voice_calls_completed');
const voiceCallsFailed = new Counter('voice_calls_failed');
const sosTriggers = new Counter('sos_triggers');
const healthChecksPassed = new Counter('health_checks_passed');
const apiErrorRate = new Rate('api_error_rate');
const p95Latency = new Trend('p95_latency', true);
const p99Latency = new Trend('p99_latency', true);
const activeConnections = new Gauge('active_connections');

// ═══════════════════════════════════════════════════════════════
// SCENARIO CONFIGURATIONS
// ═══════════════════════════════════════════════════════════════

const SCENARIOS = {
  // Quick sanity check
  smoke: {
    executor: 'constant-vus',
    vus: 5,
    duration: '1m',
  },
  // Normal daily load
  average: {
    executor: 'ramping-vus',
    startVUs: 0,
    stages: [
      { duration: '30s', target: 20 },
      { duration: '2m',  target: 50 },
      { duration: '2m',  target: 50 },
      { duration: '30s', target: 0 },
    ],
  },
  // Morning check-in surge (stress)
  stress: {
    executor: 'ramping-vus',
    startVUs: 0,
    stages: [
      { duration: '1m', target: 50 },
      { duration: '2m', target: 100 },
      { duration: '1m', target: 200 },
      { duration: '2m', target: 200 },
      { duration: '1m', target: 50 },
      { duration: '1m', target: 0 },
    ],
  },
  // Concurrent voice calls
  voice: {
    executor: 'constant-vus',
    vus: 20,
    duration: '3m',
  },
  // Emergency SOS burst
  sos: {
    executor: 'ramping-arrival-rate',
    startRate: 0,
    timeUnit: '1s',
    preAllocatedVUs: 50,
    maxVUs: 100,
    stages: [
      { duration: '10s', target: 10 },
      { duration: '20s', target: 50 },
      { duration: '30s', target: 100 },
      { duration: '30s', target: 20 },
      { duration: '30s', target: 0 },
    ],
  },
};

// Select scenario
const scenarioConfig = SCENARIOS[SCENARIO] || SCENARIOS.smoke;

export const options = {
  scenarios: {
    default: scenarioConfig,
  },
  thresholds: {
    http_req_duration: [
      'p(95)<2000',  // 95% of requests under 2s
      'p(99)<5000',  // 99% under 5s
    ],
    http_req_failed: [
      'rate<0.05',   // <5% error rate
    ],
    'api_error_rate': ['rate<0.02'], // <2% API-level errors
  },
  summaryTrendStats: ['avg', 'min', 'med', 'p(90)', 'p(95)', 'p(99)', 'max'],
};

// ═══════════════════════════════════════════════════════════════
// DEFAULT FUNCTION — Main test logic
// ═══════════════════════════════════════════════════════════════

export default function () {
  const params = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${AUTH_TOKEN}`,
      'X-Request-ID': `${__VU}-${__ITER}-${Date.now()}`,
    },
    tags: { scenario: SCENARIO },
  };

  // ─── Group 1: Health Check ─────────────────────────────────
  group('01_health_check', () => {
    const res = http.get(`${BASE_URL}/api/health`, params);
    const passed = check(res, {
      'health: status 200': (r) => r.status === 200,
      'health: response time < 500ms': (r) => r.timings.duration < 500,
      'health: body contains status': (r) => r.body.includes('ok'),
    });
    if (passed) healthChecksPassed.add(1);
    p95Latency.add(res.timings.duration);
    p99Latency.add(res.timings.duration);
  });

  sleep(Math.random() * 2);

  // ─── Group 2: Senior Profile ───────────────────────────────
  group('02_senior_profile', () => {
    const res = http.get(
      `${BASE_URL}/api/seniors/${TEST_SENIOR_ID}`,
      params,
    );
    check(res, {
      'profile: status 200 or 401': (r) => r.status === 200 || r.status === 401,
    });
    if (res.status >= 400 && res.status !== 401) {
      apiErrorRate.add(1);
    }
  });

  sleep(Math.random() * 2);

  // ─── Group 3: Health Data ──────────────────────────────────
  group('03_health_data', () => {
    // Post new health reading
    const healthPayload = JSON.stringify({
      seniorId: TEST_SENIOR_ID,
      heartRate: 60 + Math.floor(Math.random() * 40),
      steps: Math.floor(Math.random() * 5000),
      bloodOxygen: 94 + Math.floor(Math.random() * 6),
      sleepMinutes: 300 + Math.floor(Math.random() * 240),
      source: 'XIAOMI_BAND_9',
      timestamp: new Date().toISOString(),
    });

    const postRes = http.post(
      `${BASE_URL}/api/seniors/${TEST_SENIOR_ID}/health`,
      healthPayload,
      params,
    );

    check(postRes, {
      'health: POST accepted': (r) =>
        r.status === 202 || r.status === 201 || r.status === 200,
    });

    // Get latest health data
    const getRes = http.get(
      `${BASE_URL}/api/seniors/${TEST_SENIOR_ID}/health/latest`,
      params,
    );
    check(getRes, {
      'health: GET returns data': (r) =>
        r.status === 200 || r.status === 404,
    });
  });

  sleep(Math.random() * 3);

  // ─── Group 4: Voice Call Simulation ────────────────────────
  if (SCENARIO === 'voice' || SCENARIO === 'stress' || SCENARIO === 'all') {
    group('04_voice_call', () => {
      voiceCallsStarted.add(1);
      activeConnections.add(1);

      // Initiate call
      const callPayload = JSON.stringify({
        seniorId: TEST_SENIOR_ID,
        phone: '+48123456789',
        initiateCall: true,
      });

      const initRes = http.post(
        `${BASE_URL}/api/voice/calls`,
        callPayload,
        params,
      );

      const callStarted = check(initRes, {
        'voice: call initiated': (r) =>
          r.status === 202 || r.status === 200,
      });

      if (!callStarted) {
        voiceCallsFailed.add(1);
        activeConnections.add(-1);
        return;
      }

      // Simulate conversation (send transcript chunks)
      const transcripts = [
        'Dzień dobry Adamie',
        'Jak się dziś czuję?',
        'Przypomnij mi o lekach',
      ];

      for (const transcript of transcripts) {
        const transcriptRes = http.post(
          `${BASE_URL}/api/voice/transcript`,
          JSON.stringify({
            seniorId: TEST_SENIOR_ID,
            text: transcript,
            isFinal: true,
          }),
          params,
        );
        check(transcriptRes, {
          'voice: transcript accepted': (r) => r.status === 200,
        });
        sleep(1 + Math.random());
      }

      // End call
      const endRes = http.post(
        `${BASE_URL}/api/voice/calls/end`,
        JSON.stringify({ seniorId: TEST_SENIOR_ID }),
        params,
      );

      check(endRes, {
        'voice: call ended': (r) => r.status === 200,
      });

      voiceCallsCompleted.add(1);
      activeConnections.add(-1);
    });
  }

  sleep(Math.random() * 5);

  // ─── Group 5: SOS Emergency ────────────────────────────────
  if (SCENARIO === 'sos' || SCENARIO === 'all') {
    group('05_sos_emergency', () => {
      sosTriggers.add(1);

      const sosPayload = JSON.stringify({
        seniorId: TEST_SENIOR_ID,
        latitude: 52.2297 + (Math.random() - 0.5) * 0.01,
        longitude: 21.0122 + (Math.random() - 0.5) * 0.01,
        accuracy: 10 + Math.floor(Math.random() * 20),
        timestamp: new Date().toISOString(),
      });

      const sosRes = http.post(
        `${BASE_URL}/api/emergency/sos`,
        sosPayload,
        Object.assign({}, params, { timeout: '10s' }),
      );

      check(sosRes, {
        'sos: triggered successfully': (r) => r.status === 202,
        'sos: response under 3s': (r) => r.timings.duration < 3000,
      });
    });
  }

  // ─── Group 6: Notifications ────────────────────────────────
  group('06_notifications', () => {
    const notifRes = http.get(
      `${BASE_URL}/api/notifications?seniorId=${TEST_SENIOR_ID}&limit=10`,
      params,
    );
    check(notifRes, {
      'notifications: list returned': (r) =>
        r.status === 200 || r.status === 204,
    });
  });

  sleep(Math.random() * 2);
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM SUMMARY — CI-friendly output
// ═══════════════════════════════════════════════════════════════

export function handleSummary(data) {
  const summary = {
    scenario: SCENARIO,
    timestamp: new Date().toISOString(),
    metrics: {
      http_reqs: data.metrics.http_reqs?.values?.count || 0,
      http_req_failed: data.metrics.http_req_failed
        ? (data.metrics.http_req_failed.values.rate * 100).toFixed(2) + '%'
        : 'N/A',
      http_req_duration_p95:
        data.metrics.http_req_duration?.values?.['p(95)']?.toFixed(0) + 'ms' ||
        'N/A',
      http_req_duration_p99:
        data.metrics.http_req_duration?.values?.['p(99)']?.toFixed(0) + 'ms' ||
        'N/A',
      http_req_duration_avg:
        data.metrics.http_req_duration?.values?.avg?.toFixed(0) + 'ms' ||
        'N/A',
      voice_calls_started: voiceCallsStarted.name
        ? data.metrics[voiceCallsStarted.name]?.values?.count || 0
        : 0,
      voice_calls_completed: voiceCallsCompleted.name
        ? data.metrics[voiceCallsCompleted.name]?.values?.count || 0
        : 0,
      voice_calls_failed: voiceCallsFailed.name
        ? data.metrics[voiceCallsFailed.name]?.values?.count || 0
        : 0,
      sos_triggers: sosTriggers.name
        ? data.metrics[sosTriggers.name]?.values?.count || 0
        : 0,
      health_checks_passed: healthChecksPassed.name
        ? data.metrics[healthChecksPassed.name]?.values?.count || 0
        : 0,
      api_error_rate: data.metrics.api_error_rate
        ? (data.metrics.api_error_rate.values.rate * 100).toFixed(2) + '%'
        : '0.00%',
      vus_max: data.metrics.vus_max?.values?.value || 0,
      iterations: data.metrics.iterations?.values?.count || 0,
    },
  };

  // CI-friendly single-line output
  const ciLine = [
    `SCENARIO=${SCENARIO}`,
    `REQS=${summary.metrics.http_reqs}`,
    `ERR=${summary.metrics.http_req_failed}`,
    `P95=${summary.metrics.http_req_duration_p95}`,
    `P99=${summary.metrics.http_req_duration_p99}`,
    `VUS_MAX=${summary.metrics.vus_max}`,
    `ITER=${summary.metrics.iterations}`,
  ].join(' | ');

  console.log('\n📊 K6 SUMMARY: ' + ciLine + '\n');

  return {
    'stdout': textSummary(data, { indent: ' ', enableColors: true }),
    'results/summary.json': JSON.stringify(summary, null, 2),
  };
}
