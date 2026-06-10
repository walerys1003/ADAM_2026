#!/usr/bin/env bash
# =============================================================================
# Agent Adam — Comprehensive Health Check Script
# =============================================================================
# Checks all critical services and reports status.
# Exit code 0 = all healthy, non-zero = issues found.
#
# Usage:
#   ./health_check.sh                    # Check all services
#   ./health_check.sh --service api      # Check only API
#   ./health_check.sh --json             # Output as JSON
#   ./health_check.sh --alert            # Send alerts for unhealthy services
# =============================================================================

set -euo pipefail

# ---- Configuration ----
API_URL="${API_URL:-http://localhost:3000}"
NGINX_URL="${NGINX_URL:-http://localhost:80}"
REDIS_HOST="${REDIS_HOST:-localhost}"
REDIS_PORT="${REDIS_PORT:-6379}"
DB_URL="${DATABASE_URL:-postgresql://localhost:5432/senior_companion}"
HEALTHCHECK_IO_UUID="${HEALTHCHECK_IO_UUID:-}"
TIMEOUT=5
OUTPUT_FORMAT="text"

# ---- Parse Arguments ----
CHECK_ALL=true
CHECK_API=false
CHECK_DB=false
CHECK_REDIS=false
CHECK_NGINX=false
CHECK_DISK=false
SEND_ALERTS=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --service)
      CHECK_ALL=false
      case "${2:-}" in
        api) CHECK_API=true ;;
        db) CHECK_DB=true ;;
        redis) CHECK_REDIS=true ;;
        nginx) CHECK_NGINX=true ;;
        disk) CHECK_DISK=true ;;
        *) echo "Unknown service: $2"; exit 2 ;;
      esac
      shift 2
      ;;
    --json)
      OUTPUT_FORMAT="json"
      shift
      ;;
    --alert)
      SEND_ALERTS=true
      shift
      ;;
    *)
      echo "Usage: $0 [--service <name>] [--json] [--alert]"
      exit 2
      ;;
  esac
done

# ---- Status Tracking ----
declare -A STATUS
declare -A LATENCY
declare -A MESSAGES
OVERALL_HEALTHY=true

# ---- Utility Functions ----
now_ms() {
  date +%s%3N 2>/dev/null || echo $(($(date +%s) * 1000))
}

check_http() {
  local name="$1"
  local url="$2"
  local expected_code="${3:-200}"

  local start=$(now_ms)
  local response
  response=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$TIMEOUT" "$url" 2>/dev/null) || response="000"
  local end=$(now_ms)
  local latency=$((end - start))

  LATENCY[$name]=$latency

  if [ "$response" = "$expected_code" ]; then
    STATUS[$name]="HEALTHY"
    MESSAGES[$name]="OK (${latency}ms)"
    return 0
  else
    STATUS[$name]="UNHEALTHY"
    MESSAGES[$name]="HTTP ${response} (expected ${expected_code})"
    OVERALL_HEALTHY=false
    return 1
  fi
}

check_tcp() {
  local name="$1"
  local host="$2"
  local port="$3"

  local start=$(now_ms)
  if timeout "$TIMEOUT" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
    local end=$(now_ms)
    local latency=$((end - start))
    LATENCY[$name]=$latency
    STATUS[$name]="HEALTHY"
    MESSAGES[$name]="OK (${latency}ms)"
    return 0
  else
    STATUS[$name]="UNHEALTHY"
    MESSAGES[$name]="Connection refused"
    OVERALL_HEALTHY=false
    return 1
  fi
}

check_disk() {
  local name="disk"
  local usage
  usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

  if [ "$usage" -lt 85 ]; then
    STATUS[$name]="HEALTHY"
    MESSAGES[$name]="${usage}% used"
  elif [ "$usage" -lt 95 ]; then
    STATUS[$name]="WARNING"
    MESSAGES[$name]="${usage}% used — nearing capacity"
  else
    STATUS[$name]="CRITICAL"
    MESSAGES[$name]="${usage}% used — disk full!"
    OVERALL_HEALTHY=false
  fi
}

# ---- Run Checks ----
run_checks() {
  if $CHECK_ALL || $CHECK_API; then
    check_http "api" "${API_URL}/health"
  fi

  if $CHECK_ALL || $CHECK_DB; then
    # Check via API's DB health endpoint
    check_http "database" "${API_URL}/health/db"
  fi

  if $CHECK_ALL || $CHECK_REDIS; then
    check_tcp "redis" "$REDIS_HOST" "$REDIS_PORT"
  fi

  if $CHECK_ALL || $CHECK_NGINX; then
    check_http "nginx" "${NGINX_URL}/health"
  fi

  if $CHECK_ALL || $CHECK_DISK; then
    check_disk
  fi
}

# ---- Output ----
output_text() {
  echo ""
  echo "╔══════════════════════════════════════════════╗"
  echo "║     Agent Adam — Health Check Report         ║"
  echo "╠══════════════════════════════════════════════╣"

  for service in "${!STATUS[@]}"; do
    local status="${STATUS[$service]}"
    local msg="${MESSAGES[$service]}"
    local icon="✓"

    case "$status" in
      HEALTHY)  icon="🟢" ;;
      WARNING)  icon="🟡" ;;
      UNHEALTHY|CRITICAL) icon="🔴" ;;
    esac

    printf "║ %s %-12s : %s\n" "$icon" "$service" "$msg"
  done

  echo "╠══════════════════════════════════════════════╣"

  if $OVERALL_HEALTHY; then
    echo "║ 🟢 OVERALL: ALL SYSTEMS HEALTHY              ║"
  else
    echo "║ 🔴 OVERALL: ISSUES DETECTED                  ║"
  fi

  echo "╚══════════════════════════════════════════════╝"
  echo ""
}

output_json() {
  local json="{"
  local first=true

  for service in "${!STATUS[@]}"; do
    if ! $first; then json+=","; fi
    first=false
    json+="\"$service\":{\"status\":\"${STATUS[$service]}\",\"message\":\"${MESSAGES[$service]}\""
    if [ -n "${LATENCY[$service]:-}" ]; then
      json+=",\"latency_ms\":${LATENCY[$service]}"
    fi
    json+="}"
  done

  json+=",\"overall\":\"$($OVERALL_HEALTHY && echo 'healthy' || echo 'unhealthy')\""
  json+=",\"timestamp\":\"$(date -Iseconds)\""
  json+="}"

  echo "$json"
}

send_alerts() {
  if $OVERALL_HEALTHY; then
    return 0
  fi

  local alert_msg="🔴 Agent Adam Health Check FAILED\n\n"

  for service in "${!STATUS[@]}"; do
    if [ "${STATUS[$service]}" != "HEALTHY" ]; then
      alert_msg+="• $service: ${MESSAGES[$service]}\n"
    fi
  done

  alert_msg+="\nTimestamp: $(date -Iseconds)"

  # Send to alerting webhook if configured
  if [ -n "${ALERT_WEBHOOK_URL:-}" ]; then
    curl -X POST "$ALERT_WEBHOOK_URL" \
      -H "Content-Type: application/json" \
      -d "{\"text\":\"$alert_msg\"}" \
      --max-time 5 2>/dev/null || true
  fi

  echo -e "$alert_msg" >&2
}

ping_healthcheck_io() {
  if [ -n "$HEALTHCHECK_IO_UUID" ]; then
    if $OVERALL_HEALTHY; then
      curl -fsS -m 10 --retry 3 "https://hc-ping.com/$HEALTHCHECK_IO_UUID" >/dev/null 2>&1 || true
    else
      curl -fsS -m 10 --retry 3 "https://hc-ping.com/$HEALTHCHECK_IO_UUID/fail" >/dev/null 2>&1 || true
    fi
  fi
}

# ---- Main Execution ----
main() {
  run_checks

  case "$OUTPUT_FORMAT" in
    json) output_json ;;
    text) output_text ;;
  esac

  if $SEND_ALERTS; then
    send_alerts
  fi

  ping_healthcheck_io

  $OVERALL_HEALTHY && exit 0 || exit 1
}

main
