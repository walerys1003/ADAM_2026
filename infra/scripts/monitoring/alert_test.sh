#!/usr/bin/env bash
# =============================================================================
# Agent Adam — Alert Testing Script
# =============================================================================
# Tests that all alert channels are working correctly.
# Sends test alerts to:
# - Push notifications (family mobile)
# - SMS (family phone)
# - Email (family email)
# - Slack/Teams webhook (admin)
#
# Usage:
#   ./alert_test.sh --all              # Test all channels
#   ./alert_test.sh --channel push     # Test only push
#   ./alert_test.sh --channel sms      # Test only SMS
#   ./alert_test.sh --senior-id <id>   # Target specific senior
# =============================================================================

set -euo pipefail

# ---- Configuration ----
API_URL="${API_URL:-http://localhost:3000}"
ALERT_WEBHOOK_URL="${ALERT_WEBHOOK_URL:-}"
TEST_SENIOR_ID="${TEST_SENIOR_ID:-senior-001}"
TEST_FAMILY_ID="${TEST_FAMILY_ID:-family-001}"
TEST_PHONE="${TEST_PHONE:-+48123456789}"
TEST_EMAIL="${TEST_EMAIL:-test@agent-adam.local}"
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[1;33m'
COLOR_RESET='\033[0m'

# ---- Parse Arguments ----
TEST_ALL=true
TEST_PUSH=false
TEST_SMS=false
TEST_EMAIL=false
TEST_SLACK=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --all)
      TEST_ALL=true
      shift
      ;;
    --channel)
      TEST_ALL=false
      case "${2:-}" in
        push) TEST_PUSH=true ;;
        sms) TEST_SMS=true ;;
        email) TEST_EMAIL=true ;;
        slack) TEST_SLACK=true ;;
        *)
          echo "Unknown channel: $2"
          echo "Available: push, sms, email, slack"
          exit 1
          ;;
      esac
      shift 2
      ;;
    --senior-id)
      TEST_SENIOR_ID="$2"
      shift 2
      ;;
    *)
      echo "Usage: $0 [--all] [--channel <name>] [--senior-id <id>]"
      exit 1
      ;;
  esac
done

# ---- Utility Functions ----
check_result() {
  local name="$1"
  local result="$2"

  if [ "$result" -eq 0 ]; then
    echo -e "${COLOR_GREEN}✓${COLOR_RESET} $name: PASSED"
    return 0
  else
    echo -e "${COLOR_RED}✗${COLOR_RESET} $name: FAILED"
    return 1
  fi
}

# ---- Test Functions ----
test_push() {
  echo -e "\n${COLOR_YELLOW}Testing Push Notification...${COLOR_RESET}"

  local response
  response=$(curl -s -w "\n%{http_code}" -X POST "${API_URL}/api/test/alert/push" \
    -H "Content-Type: application/json" \
    -H "X-Test-Mode: true" \
    -d "{
      \"seniorId\": \"${TEST_SENIOR_ID}\",
      \"familyIds\": [\"${TEST_FAMILY_ID}\"],
      \"type\": \"TEST_ALERT\",
      \"title\": \"Test Alert — Agent Adam Monitoring\",
      \"body\": \"This is a test push notification from the alert testing script.\",
      \"semaforLevel\": \"GREEN\"
    }" 2>/dev/null)

  local http_code
  http_code=$(echo "$response" | tail -1)

  if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
    check_result "Push notification" 0
  else
    check_result "Push notification (HTTP $http_code)" 1
  fi
}

test_sms() {
  echo -e "\n${COLOR_YELLOW}Testing SMS Alert...${COLOR_RESET}"

  local response
  response=$(curl -s -w "\n%{http_code}" -X POST "${API_URL}/api/test/alert/sms" \
    -H "Content-Type: application/json" \
    -H "X-Test-Mode: true" \
    -d "{
      \"phone\": \"${TEST_PHONE}\",
      \"message\": \"[TEST] Agent Adam monitoring - SMS alert test. Please ignore.\"
    }" 2>/dev/null)

  local http_code
  http_code=$(echo "$response" | tail -1)

  if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
    check_result "SMS alert" 0
  else
    check_result "SMS alert (HTTP $http_code)" 1
  fi
}

test_email() {
  echo -e "\n${COLOR_YELLOW}Testing Email Alert...${COLOR_RESET}"

  local response
  response=$(curl -s -w "\n%{http_code}" -X POST "${API_URL}/api/test/alert/email" \
    -H "Content-Type: application/json" \
    -H "X-Test-Mode: true" \
    -d "{
      \"email\": \"${TEST_EMAIL}\",
      \"subject\": \"[TEST] Agent Adam — Email Alert Test\",
      \"template\": \"alert_notification\",
      \"data\": {
        \"seniorName\": \"Test Senior\",
        \"alertType\": \"TEST\",
        \"semaforLevel\": \"GREEN\",
        \"timestamp\": \"$(date -Iseconds)\",
        \"details\": \"This is a test email from the alert monitoring script.\"
      }
    }" 2>/dev/null)

  local http_code
  http_code=$(echo "$response" | tail -1)

  if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
    check_result "Email alert" 0
  else
    check_result "Email alert (HTTP $http_code)" 1
  fi
}

test_slack() {
  echo -e "\n${COLOR_YELLOW}Testing Slack Webhook...${COLOR_RESET}"

  if [ -z "$ALERT_WEBHOOK_URL" ]; then
    echo -e "${COLOR_YELLOW}⚠${COLOR_RESET} Slack: SKIPPED (ALERT_WEBHOOK_URL not set)"
    return 0
  fi

  local response
  response=$(curl -s -w "\n%{http_code}" -X POST "${ALERT_WEBHOOK_URL}" \
    -H "Content-Type: application/json" \
    -d "{
      \"text\": \"🧪 *Agent Adam Alert Test*\n\nThis is a test alert from the monitoring script.\n\n• Senior: ${TEST_SENIOR_ID}\n• Level: GREEN (test)\n• Timestamp: $(date -Iseconds)\n• Status: All systems operational\"
    }" 2>/dev/null)

  local http_code
  http_code=$(echo "$response" | tail -1)

  if [ "$http_code" = "200" ]; then
    check_result "Slack webhook" 0
  else
    check_result "Slack webhook (HTTP $http_code)" 1
  fi
}

test_semafor_flow() {
  echo -e "\n${COLOR_YELLOW}Testing Semafor Escalation Flow...${COLOR_RESET}"

  local levels=("GREEN" "YELLOW" "ORANGE" "RED" "PURPLE")
  local all_passed=true

  for level in "${levels[@]}"; do
    local response
    response=$(curl -s -w "\n%{http_code}" -X POST "${API_URL}/api/test/alert/semafor" \
      -H "Content-Type: application/json" \
      -H "X-Test-Mode: true" \
      -d "{
        \"seniorId\": \"${TEST_SENIOR_ID}\",
        \"semaforLevel\": \"${level}\",
        \"healthData\": {
          \"heartRate\": 72,
          \"bloodPressureSystolic\": 120,
          \"bloodPressureDiastolic\": 80,
          \"bloodOxygen\": 98
        }
      }" 2>/dev/null)

    local http_code
    http_code=$(echo "$response" | tail -1)

    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
      echo -e "  ${COLOR_GREEN}✓${COLOR_RESET} Semafor ${level}: Alert triggered correctly"
    else
      echo -e "  ${COLOR_RED}✗${COLOR_RESET} Semafor ${level}: Failed (HTTP ${http_code})"
      all_passed=false
    fi
  done

  if $all_passed; then
    check_result "Semafor escalation flow" 0
  else
    check_result "Semafor escalation flow" 1
  fi
}

# ---- Main ----
main() {
  echo "╔══════════════════════════════════════════════╗"
  echo "║     Agent Adam — Alert Testing Suite         ║"
  echo "╠══════════════════════════════════════════════╣"
  echo "║ Senior ID : ${TEST_SENIOR_ID}                   ║"
  echo "║ Family ID : ${TEST_FAMILY_ID}                   ║"
  echo "║ API URL   : ${API_URL}       ║"
  echo "╚══════════════════════════════════════════════╝"

  local exit_code=0

  if $TEST_ALL || $TEST_PUSH; then
    test_push || exit_code=1
  fi

  if $TEST_ALL || $TEST_SMS; then
    test_sms || exit_code=1
  fi

  if $TEST_ALL || $TEST_EMAIL; then
    test_email || exit_code=1
  fi

  if $TEST_ALL || $TEST_SLACK; then
    test_slack || exit_code=1
  fi

  if $TEST_ALL; then
    test_semafor_flow || exit_code=1
  fi

  echo ""
  if [ "$exit_code" -eq 0 ]; then
    echo -e "${COLOR_GREEN}═══════════════════════════════════════════${COLOR_RESET}"
    echo -e "${COLOR_GREEN}   ALL ALERT TESTS PASSED                  ${COLOR_RESET}"
    echo -e "${COLOR_GREEN}═══════════════════════════════════════════${COLOR_RESET}"
  else
    echo -e "${COLOR_RED}═══════════════════════════════════════════${COLOR_RESET}"
    echo -e "${COLOR_RED}   SOME TESTS FAILED — CHECK OUTPUT ABOVE  ${COLOR_RESET}"
    echo -e "${COLOR_RED}═══════════════════════════════════════════${COLOR_RESET}"
  fi

  exit $exit_code
}

main
