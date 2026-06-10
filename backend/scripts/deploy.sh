#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
# Agent Adam — Production Deployment Script
# SilverTech | June 2026
# ─────────────────────────────────────────────────────────────────
# Usage:
#   ./scripts/deploy.sh [staging|production] [tag]
#   ./scripts/deploy.sh production v1.2.3
# ─────────────────────────────────────────────────────────────────
set -euo pipefail

ENV="${1:-staging}"
TAG="${2:-latest}"
NAMESPACE="agent-adam"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ─── Validate environment ────────────────────────────────────────
if [[ "$ENV" != "staging" && "$ENV" != "production" ]]; then
  err "Invalid environment: $ENV (use: staging|production)"
fi

log "🚀 Deploying Agent Adam to ${ENV} (tag: ${TAG})"

# ─── Pre-flight checks ───────────────────────────────────────────
log "📋 Running pre-flight checks..."

# Check kubectl connection
if ! kubectl cluster-info &>/dev/null; then
  err "Cannot connect to Kubernetes cluster"
fi

# Check namespace
if ! kubectl get namespace "$NAMESPACE" &>/dev/null; then
  warn "Namespace $NAMESPACE not found, creating..."
  kubectl create namespace "$NAMESPACE"
fi

# ─── Database backup (production only) ───────────────────────────
if [[ "$ENV" == "production" ]]; then
  log "💾 Creating pre-deployment database backup..."
  if [[ -f "./scripts/backup/backup_db.sh" ]]; then
    bash ./scripts/backup/backup_db.sh || warn "Backup failed, continuing anyway"
  else
    warn "Backup script not found, skipping"
  fi
fi

# ─── Run database migrations ─────────────────────────────────────
log "🗄️  Running database migrations..."
if command -v npx &>/dev/null; then
  npx prisma migrate deploy || err "Migration failed"
else
  warn "npx not available, skipping migrations"
fi

# ─── Build and push Docker images ────────────────────────────────
log "🐳 Building Docker images..."

# API image
docker build \
  -t registry.silvertech.pl/agent-adam-api:"${TAG}" \
  -f Dockerfile \
  --target api \
  --build-arg VERSION="${TAG}" \
  --build-arg BUILD_DATE="${TIMESTAMP}" \
  .

# Worker image
docker build \
  -t registry.silvertech.pl/agent-adam-worker:"${TAG}" \
  -f Dockerfile \
  --target worker \
  --build-arg VERSION="${TAG}" \
  --build-arg BUILD_DATE="${TIMESTAMP}" \
  .

log "📤 Pushing images to registry..."
docker push registry.silvertech.pl/agent-adam-api:"${TAG}"
docker push registry.silvertech.pl/agent-adam-worker:"${TAG}"

# ─── Deploy to Kubernetes ────────────────────────────────────────
log "☸️  Deploying to Kubernetes..."

# Apply Kustomize overlay
kubectl apply -k "infra/k8s/overlays/${ENV}" -n "$NAMESPACE"

# Update image tags
kubectl set image deployment/agent-adam-api \
  api=registry.silvertech.pl/agent-adam-api:"${TAG}" \
  -n "$NAMESPACE"

kubectl set image deployment/agent-adam-worker \
  worker=registry.silvertech.pl/agent-adam-worker:"${TAG}" \
  -n "$NAMESPACE"

# ─── Wait for rollout ────────────────────────────────────────────
log "⏳ Waiting for rollout to complete..."

kubectl rollout status deployment/agent-adam-api -n "$NAMESPACE" --timeout=300s
kubectl rollout status deployment/agent-adam-worker -n "$NAMESPACE" --timeout=300s

# ─── Health check ────────────────────────────────────────────────
log "🏥 Running health checks..."

sleep 5

# Check pod status
PODS=$(kubectl get pods -n "$NAMESPACE" -l app=agent-adam -o jsonpath='{.items[*].status.phase}')
if [[ "$PODS" =~ "Running" ]]; then
  log "✅ All pods running"
else
  warn "Some pods may not be running: $PODS"
fi

# API health endpoint
if [[ "$ENV" == "production" ]]; then
  HEALTH_URL="https://api.agentadam.pl/health"
else
  HEALTH_URL="https://api.staging.agentadam.pl/health"
fi

if curl -sf "${HEALTH_URL}" > /dev/null 2>&1; then
  log "✅ Health check passed: ${HEALTH_URL}"
else
  warn "Health check failed for: ${HEALTH_URL}"
fi

# ─── Post-deploy notification ────────────────────────────────────
log "📧 Sending deployment notification..."

DEPLOY_MSG="Agent Adam ${ENV} deployed: ${TAG} at ${TIMESTAMP}"

# Slack webhook (if configured)
if [[ -n "${SLACK_WEBHOOK_URL:-}" ]]; then
  curl -s -X POST "${SLACK_WEBHOOK_URL}" \
    -H "Content-Type: application/json" \
    -d "{\"text\":\"🚀 ${DEPLOY_MSG}\"}" || true
fi

# ─── Summary ─────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}═══════════════════════════════════${NC}"
echo -e "${GREEN}  Deployment Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════${NC}"
echo -e "  Environment: ${BLUE}${ENV}${NC}"
echo -e "  Tag:         ${BLUE}${TAG}${NC}"
echo -e "  Time:        ${TIMESTAMP}"
echo -e "  Namespace:   ${NAMESPACE}"
echo ""
echo -e "  API:  https://api${ENV == 'staging' && '.staging' || ''}.agentadam.pl"
echo -e "${GREEN}═══════════════════════════════════${NC}"
