/**
 * SilverTech Agent Adam — k6 Load Test Script
 * Tests API endpoints under concurrent load
 * 
 * Run: k6 run tests/performance/k6_load_test.js
 * 
 * Scenarios:
 * 1. Smoke test: 10 VUs, 1 min
 * 2. Load test: 50 VUs, 5 min
 * 3. Stress test: 200 VUs, 10 min
 * 4. Soak test: 30 VUs, 30 min
 */

import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const apiLatency = new Trend('api_latency');
const callsStarted = new Counter('calls_started');
const callsCompleted = new Counter('calls_completed');

// Configuration
const BASE_URL = __ENV.API_URL || 'https://api.silvertech.ai';
const API_KEY = __ENV.API_KEY || 'test-api-key';

export const options = {
  scenarios: {
    // ── Smoke Test ──────────────────────────────────
    smoke: {
      executor: 'constant-vus',
      vus: 10,
      duration: '1m',
      tags: { test_type: 'smoke' },
    },

    // ── Average Load ────────────────────────────────
    average_load: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '1m', target: 20 },   // Ramp up
        { duration: '3m', target: 20 },   // Steady state
        { duration: '1m', target: 0 },    // Ramp down
      ],
      tags: { test_type: 'load' },
    },

    // ── Stress Test ─────────────────────────────────
    stress: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '2m', target: 50 },
        { duration: '1m', target: 100 },
        { duration: '1m', target: 200 },
        { duration: '2m', target: 200 },
        { duration: '2m', target: 0 },
      ],
      tags: { test_type: 'stress' },
    },

    // ── Spike Test ──────────────────────────────────
    spike: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '30s', target: 300 },   // Sudden spike
        { duration: '10s', target: 300 },   // Hold
        { duration: '30s', target: 0 },     // Back to normal
      ],
      tags: { test_type: 'spike' },
    },
  },

  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],   // 95% < 500ms, 99% < 1s
    http_req_failed: ['rate<0.01'],                     // < 1% error rate
    errors: ['rate<0.05'],                               // < 5% app errors
    api_latency: ['p(95)<300'],                          // API latency < 300ms
  },

  // Ramp down scenarios (for testing individual scenarios)
  // Uncomment to run a single scenario:
  // scenarios: {
  //   smoke: options.scenarios.smoke,
  // },
};

// ── Default Function ──────────────────────────────────
export default function () {
  const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${API_KEY}`,
  };

  group('Health Check', () => {
    const res = http.get(`${BASE_URL}/api/health`, { headers });
    check(res, {
      'health status 200': (r) => r.status === 200,
      'response status ok': (r) => JSON.parse(r.body).status === 'ok',
    });
    apiLatency.add(res.timings.duration);
    errorRate.add(res.status !== 200);
  });

  group('Auth - Login', () => {
    const payload = JSON.stringify({
      email: 'senior1@test.com',
      password: 'testpassword123',
    });

    const res = http.post(`${BASE_URL}/api/auth/login`, payload, {
      headers: { ...headers, 'Content-Type': 'application/json' },
    });

    check(res, {
      'login status 200': (r) => r.status === 200,
      'has access token': (r) => JSON.parse(r.body).accessToken !== undefined,
    });
    apiLatency.add(res.timings.duration);
    errorRate.add(res.status !== 200);
  });

  group('Seniors List', () => {
    const res = http.get(`${BASE_URL}/api/seniors?page=1&limit=10`, { headers });
    check(res, {
      'seniors list 200': (r) => r.status === 200,
      'has data array': (r) => Array.isArray(JSON.parse(r.body).data),
    });
    apiLatency.add(res.timings.duration);
    errorRate.add(res.status !== 200);
  });

  group('Dashboard', () => {
    const res = http.get(`${BASE_URL}/api/admin/dashboard`, { headers });
    check(res, {
      'dashboard 200': (r) => r.status === 200,
      'has total seniors': (r) => JSON.parse(r.body).totalSeniors !== undefined,
    });
    apiLatency.add(res.timings.duration);
    errorRate.add(res.status !== 200);
  });

  // Simulate voice call start/end cycle
  group('Voice Call Lifecycle', () => {
    const startPayload = JSON.stringify({
      senior_id: 'test-senior-001',
      caller_number: '+48123456789',
    });

    // Start call
    const startRes = http.post(`${BASE_URL}/api/voice/call/start`, startPayload, {
      headers: { ...headers, 'Content-Type': 'application/json' },
    });

    callsStarted.add(1);

    if (startRes.status === 201) {
      const body = JSON.parse(startRes.body);

      // End call
      sleep(1);
      const endPayload = JSON.stringify({
        call_id: body.call_id,
        reason: 'normal',
        duration_seconds: 60,
      });

      const endRes = http.post(`${BASE_URL}/api/voice/call/end`, endPayload, {
        headers: { ...headers, 'Content-Type': 'application/json' },
      });

      callsCompleted.add(1);
      check(endRes, { 'call ended 200': (r) => r.status === 200 });
    }

    errorRate.add(startRes.status !== 201);
  });

  group('Health Data', () => {
    const payload = JSON.stringify({
      senior_id: 'test-senior-001',
      data: {
        heart_rate: 72,
        steps: 4823,
        spo2: 97,
        sleep_hours: 7.5,
      },
    });

    const res = http.post(`${BASE_URL}/api/health/wearable/sync`, payload, {
      headers: { ...headers, 'Content-Type': 'application/json' },
    });

    check(res, {
      'health sync 201': (r) => r.status === 201,
    });
    apiLatency.add(res.timings.duration);
  });

  sleep(2); // Think time between iterations
}

// ── Custom Summary ─────────────────────────────────────
export function handleSummary(data) {
  return {
    'k6_summary.json': JSON.stringify(data),
    stdout: `
============================================
  Agent Adam — Load Test Summary
============================================
  Total Requests:    ${data.metrics.http_reqs.values.count}
  Failed Requests:   ${data.metrics.http_req_failed.values.passes || 0}
  Avg Duration:      ${data.metrics.http_req_duration.values.avg.toFixed(2)}ms
  P95 Duration:      ${data.metrics.http_req_duration.values['p(95)'].toFixed(2)}ms
  P99 Duration:      ${data.metrics.http_req_duration.values['p(99)'].toFixed(2)}ms
  Error Rate:        ${(data.metrics.errors?.values.rate * 100 || 0).toFixed(2)}%
  VUs:               ${data.metrics.vus.values.max}
  Duration:          ${data.state.testRunDurationMs / 1000}s
============================================
    `,
  };
}
