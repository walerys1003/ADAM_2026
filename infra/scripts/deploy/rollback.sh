#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
# Agent Adam — Rollback Script
# SilverTech | June 2026
# ─────────────────────────────────────────────────────────────────
# Usage: ./scripts/deploy/rollback.sh [environment] [deployment]
# Example: ./scripts/deploy/rollback.sh production agent-adam-api
# ─────────────────────────────────────────────────────────────────
set -euo pipefail

ENV="${1:-production}"
DEPLOYMENT="${2:-agent-adam-api}"
NAMESPACE="agent-adam"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

log "⏪ Rolling back ${DEPLOYMENT} in ${ENV}..."

# ─── Show rollout history ─────────────────────────────────────────
log "📜 Recent rollout history:"
kubectl rollout history deployment/"${DEPLOYMENT}" -n "$NAMESPACE" | tail -5

# ─── Get previous revision ────────────────────────────────────────
PREV_REVISION=$(kubectl rollout history deployment/"${DEPLOYMENT}" -n "$NAMESPACE" \
  | grep -v "REVISION" | tail -2 | head -1 | awk '{print $1}')

if [[ -z "$PREV_REVISION" ]]; then
  err "Cannot find previous revision for rollback"
fi

log "🔄 Rolling back to revision ${PREV_REVISION}..."

kubectl rollout undo deployment/"${DEPLOYMENT}" \
  -n "$NAMESPACE" \
  --to-revision="${PREV_REVISION}"

# ─── Wait for rollback to complete ────────────────────────────────
log "⏳ Waiting for rollback to complete..."
if kubectl rollout status deployment/"${DEPLOYMENT}" -n "$NAMESPACE" --timeout=180s; then
  log "✅ Rollback successful!"
else
  log "⚠️  Rollback may not have completed. Manual check required."
fi

# ─── Verify pods ──────────────────────────────────────────────────
log "📋 Current pod status:"
kubectl get pods -n "$NAMESPACE" -l "app=${DEPLOYMENT}" -o wide

log "⏪ Rollback process complete."
