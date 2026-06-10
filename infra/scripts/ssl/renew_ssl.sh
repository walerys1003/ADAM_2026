#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
# Agent Adam — SSL Certificate Renewal Script
# SilverTech | June 2026
# ─────────────────────────────────────────────────────────────────
# Handles auto-renewal of Let's Encrypt certificates via cert-manager
# Runs as a CronJob in Kubernetes (weekly)
# ─────────────────────────────────────────────────────────────────
set -euo pipefail

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"; }

DOMAINS=(
  "api.agentadam.pl"
  "api.staging.agentadam.pl"
  "agentadam.pl"
  "www.agentadam.pl"
)

RENEWAL_THRESHOLD_DAYS=30
NAMESPACE="agent-adam"

log "🔐 Starting SSL certificate check..."

for DOMAIN in "${DOMAINS[@]}"; do
  log "Checking certificate for ${DOMAIN}..."
  
  # Get certificate status from cert-manager
  CERT_STATUS=$(kubectl get certificate -n "$NAMESPACE" \
    -l "domain=${DOMAIN}" \
    -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "Unknown")

  if [[ "$CERT_STATUS" != "True" ]]; then
    log "⚠️  Certificate for ${DOMAIN} is not ready (status: ${CERT_STATUS})"
    
    # Check if certificate exists
    if ! kubectl get certificate -n "$NAMESPACE" \
      -l "domain=${DOMAIN}" &>/dev/null; then
      log "Certificate for ${DOMAIN} does not exist — skipping"
      continue
    fi
  fi

  # Get expiration date
  EXPIRY=$(kubectl get certificate -n "$NAMESPACE" \
    -l "domain=${DOMAIN}" \
    -o jsonpath='{.items[0].status.notAfter}' 2>/dev/null || echo "")

  if [[ -n "$EXPIRY" ]]; then
    EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$EXPIRY" +%s 2>/dev/null)
    NOW_EPOCH=$(date +%s)
    DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))

    if [[ $DAYS_LEFT -le $RENEWAL_THRESHOLD_DAYS ]]; then
      log "🔄 ${DOMAIN} expires in ${DAYS_LEFT} days — triggering renewal..."
      
      # Delete the secret to force cert-manager to renew
      kubectl delete secret -n "$NAMESPACE" \
        -l "cert-manager.io/certificate-name" 2>/dev/null || true
      
      log "✅ Renewal triggered for ${DOMAIN}"
    else
      log "✅ ${DOMAIN} valid for ${DAYS_LEFT} more days"
    fi
  fi
done

# Wait for new certificates to be issued
log "⏳ Waiting for certificate renewal (max 120s)..."
kubectl wait --for=condition=ready certificate \
  --all -n "$NAMESPACE" \
  --timeout=120s 2>/dev/null || log "⚠️  Some certificates may still be provisioning"

# Verify all certificates
log "📋 Final certificate status:"
kubectl get certificates -n "$NAMESPACE" -o wide

log "🔐 SSL check complete!"
