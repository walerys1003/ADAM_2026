/**
 * SilverTech Agent Adam — k6 Load Test Configuration
 * Performance testing for API endpoints:
 * - Smoke test: baseline verification
 * - Load test: expected production traffic
 * - Stress test: find breaking point
 * - Soak test: long-duration stability
 * - Spike test: sudden traffic surge
 *
 * Usage:
 *   k6 run tests/performance/k6-load-test.js
 *   k6 run --env SCENARIO=stress tests/performance/k6-load-test.js
 *   k6 run --env BASE_URL=https://staging.silvertech.ai tests/performance/k6-load-test.js
 */

import http from 'k6/http';
import { sleep, check, group, trend } from 'k6';
import { Rate, Counter } from 'k6/metrics';

// ─── Custom Metrics ──────────────────────────────────────────────
const errorRate = new Rate('errors');
const voiceCallRate = new Rate('voice_calls');
const healthCheckLatency = new Trend('health_check_latency');
const authLatency = new Trend('auth_latency');
const seniorDataLatency = new Trend('senior_data_latency');
const apiTotalRequests = new Counter('total_requests');

// ─── Configuration ───────────────────────────────────────────────
const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';
const SCENARIO = __ENV.SCENARIO || 'smoke';
const RAMP_TIME = __ENV.RAMP_TIME || '30s';
const DURATION = __ENV.DURATION || '1m';

// Test data
const TEST_SENIORS = [
  { id: 'senior-001', name: 'Jan Kowalski', package: 'ZDROWIE' },
  { id: 'senior-002', name: 'Maria Nowak', package: 'KONTAKT' },
  { id: 'senior-003', name: 'Stanisław Kowalczyk', package: 'AKTYWNY' },
];

const TEST_FAMILY = [
  { id: 'family-001', name: 'Anna Kowalska', email: 'anna@example.com' },
  { id: 'family-002', name: 'Piotr Nowak', email: 'piotr@example.com' },
];

// ─── Scenarios ────────────────────────────────────────────────────
export const options = {
  scenarios: {
    smoke: {
      executor: 'constant-vus',
      vus: 5,
      duration: '1m',
      gracefulStop: '10s',
      tags: { scenario: 'smoke' },
    },
    load: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '2m', target: 50 },
        { duration: '5m', target: 50 },
        { duration: '2m', target: 100 },
        { duration: '5m', target: 100 },
        { duration: '2m', target: 0 },
      ],
      gracefulRampDown: '30s',
      tags: { scenario: 'load' },
    },
    stress: {
      executor: 'ramping-arrival-rate',
      startRate: 10,
      timeUnit: '1s',
      preAllocatedVUs: 50,
      maxVUs: 200,
      stages: [
        { duration: '1m', target: 10 },
        { duration: '3m', target: 50 },
        { duration: '3m', target: 100 },
        { duration: '2m', target: 150 },
        { duration: '1m', target: 10 },
      ],
      tags: { scenario: 'stress' },
    },
    soak: {
      executor: 'constant-vus',
      vus: 30,
      duration: '30m',
      gracefulStop: '30s',
      tags: { scenario: 'soak' },
    },
    spike: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '30s', target: 10 },
        { duration: '10s', target: 200 },
        { duration: '30s', target: 200 },
        { duration: '10s', target: 10 },
        { duration: '30s', target: 0 },
      ],
      gracefulRampDown: '10s',
      tags: { scenario: 'spike' },
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<2000', 'p(99)<5000'],
    errors: ['rate<0.05'],
    'http_req_duration{endpoint:health}': ['p(95)<500'],
    'http_req_duration{endpoint:voice_start}': ['p(95)<3000'],
    'http_req_duration{endpoint:senior_data}': ['p(95)<1000'],
  },
};

// ─── Default Function ─────────────────────────────────────────────

export default function () {
  const scenario = SCENARIO;

  group('Health & Readiness', () => {
    healthCheck();
  });

  group('Authentication', () => {
    familyAuth();
  });

  group('Senior Data', () => {
    getSeniorProfile();
    getSeniorHealth();
    getSeniorMedications();
  });

  group('Family Dashboard', () => {
    getFamilyDashboard();
    getWeeklyReport();
  });

  group('Voice Calls', () => {
    initiateVoiceCall();
  });

  group('Landing Page', () => {
    getBlogPosts();
    getPricing();
    submitContactForm();
  });

  // Think time simulation
  sleep(Math.random() * 3 + 1);
}

// ─── API Functions ────────────────────────────────────────────────

function healthCheck() {
  const start = Date.now();
  const res = http.get(`${BASE_URL}/api/health`, {
    tags: { endpoint: 'health' },
  });

  healthCheckLatency.add(Date.now() - start);
  apiTotalRequests.add(1);

  check(res, {
    'health: status 200': (r) => r.status === 200,
    'health: ok': (r) => r.json('status') === 'ok',
  }) || errorRate.add(1);
}

function familyAuth() {
  const family = TEST_FAMILY[Math.floor(Math.random() * TEST_FAMILY.length)];

  const start = Date.now();
  const res = http.post(`${BASE_URL}/api/v1/auth/family/login`, JSON.stringify({
    email: family.email,
    password: 'testPassword123!',
  }), {
    headers: { 'Content-Type': 'application/json' },
    tags: { endpoint: 'auth' },
  });

  authLatency.add(Date.now() - start);
  apiTotalRequests.add(1);

  check(res, {
    'auth: status 200 or 401': (r) => r.status === 200 || r.status === 401,
  }) || errorRate.add(1);
}

function getSeniorProfile() {
  const senior = TEST_SENIORS[Math.floor(Math.random() * TEST_SENIORS.length)];

  const start = Date.now();
  const res = http.get(`${BASE_URL}/api/v1/seniors/${senior.id}/profile`, {
    tags: { endpoint: 'senior_data' },
  });

  seniorDataLatency.add(Date.now() - start);
  apiTotalRequests.add(1);

  check(res, {
    'senior profile: status 200 or 404': (r) => r.status === 200 || r.status === 404,
  }) || errorRate.add(1);
}

function getSeniorHealth() {
  const senior = TEST_SENIORS[Math.floor(Math.random() * TEST_SENIORS.length)];

  const res = http.get(`${BASE_URL}/api/v1/seniors/${senior.id}/health?days=7`, {
    tags: { endpoint: 'senior_health' },
  });

  apiTotalRequests.add(1);
  check(res, {
    'health data: status 200 or 404': (r) => r.status === 200 || r.status === 404,
  }) || errorRate.add(1);
}

function getSeniorMedications() {
  const senior = TEST_SENIORS[Math.floor(Math.random() * TEST_SENIORS.length)];

  const res = http.get(`${BASE_URL}/api/v1/seniors/${senior.id}/medications`, {
    tags: { endpoint: 'medications' },
  });

  apiTotalRequests.add(1);
  check(res, {
    'medications: status 200 or 404': (r) => r.status === 200 || r.status === 404,
  }) || errorRate.add(1);
}

function getFamilyDashboard() {
  const res = http.get(`${BASE_URL}/api/v1/family/dashboard`, {
    tags: { endpoint: 'family_dashboard' },
  });

  apiTotalRequests.add(1);
  check(res, {
    'dashboard: status 200 or 401': (r) => r.status === 200 || r.status === 401,
  }) || errorRate.add(1);
}

function getWeeklyReport() {
  const senior = TEST_SENIORS[Math.floor(Math.random() * TEST_SENIORS.length)];

  const res = http.get(`${BASE_URL}/api/v1/family/reports/weekly/${senior.id}`, {
    tags: { endpoint: 'weekly_report' },
  });

  apiTotalRequests.add(1);
  check(res, {
    'weekly report: status 200 or 404': (r) => r.status === 200 || r.status === 404,
  }) || errorRate.add(1);
}

function initiateVoiceCall() {
  // Only 10% of VUs initiate voice calls
  if (Math.random() > 0.1) return;

  const senior = TEST_SENIORS[Math.floor(Math.random() * TEST_SENIORS.length)];

  const res = http.post(`${BASE_URL}/api/v1/voice/call`, JSON.stringify({
    seniorId: senior.id,
    type: 'outbound',
  }), {
    headers: { 'Content-Type': 'application/json' },
    tags: { endpoint: 'voice_start' },
  });

  apiTotalRequests.add(1);
  voiceCallRate.add(1);

  check(res, {
    'voice call: status 200 or 503': (r) => r.status === 200 || r.status === 503,
  }) || errorRate.add(1);
}

function getBlogPosts() {
  const res = http.get(`${BASE_URL}/api/v1/blog?limit=3`, {
    tags: { endpoint: 'blog' },
  });

  apiTotalRequests.add(1);
  check(res, {
    'blog: status 200': (r) => r.status === 200,
  }) || errorRate.add(1);
}

function getPricing() {
  const res = http.get(`${BASE_URL}/api/v1/pricing`, {
    tags: { endpoint: 'pricing' },
  });

  apiTotalRequests.add(1);
  check(res, {
    'pricing: status 200': (r) => r.status === 200,
  }) || errorRate.add(1);
}

function submitContactForm() {
  // Only 5% of VUs submit contact form
  if (Math.random() > 0.05) return;

  const res = http.post(`${BASE_URL}/api/v1/contact`, JSON.stringify({
    name: 'Test User',
    email: `test_${Date.now()}@example.com`,
    message: 'Test message from k6 load test',
    interest: 'ZDROWIE',
  }), {
    headers: { 'Content-Type': 'application/json' },
    tags: { endpoint: 'contact' },
  });

  apiTotalRequests.add(1);
  check(res, {
    'contact: status 200 or 429': (r) => r.status === 200 || r.status === 429,
  }) || errorRate.add(1);
}

// ─── Teardown ─────────────────────────────────────────────────────

export function teardown() {
  console.log(`\n=== Agent Adam Load Test Complete ===`);
  console.log(`Scenario: ${SCENARIO}`);
  console.log(`Base URL: ${BASE_URL}`);
  console.log(`Total Requests: ${apiTotalRequests.name}`);
  console.log(`Error Rate: ${errorRate.name}`);
  console.log(`===================================\n`);
}
