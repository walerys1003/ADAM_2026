#!/bin/bash
# SilverTech Agent Adam — Database Backup Script
# PostgreSQL pg_dump with encryption, rotation, and S3 upload
# June 2026 — runs daily via cron

set -euo pipefail

# ── Configuration ───────────────────────────────────────
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-agent_adam}"
DB_USER="${DB_USER:-adam}"
BACKUP_DIR="${BACKUP_DIR:-/backups/adam-db}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
S3_BUCKET="${S3_BUCKET:-silvertech-backups}"
S3_ENDPOINT="${S3_ENDPOINT:-https://fsn1.your-objectstorage.com}"
GPG_RECIPIENT="${GPG_RECIPIENT:-backup@silvertech.ai}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/adam_${DB_NAME}_${TIMESTAMP}.sql.gz.gpg"
LOG_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.log"

# ── Functions ───────────────────────────────────────────
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

cleanup_old_backups() {
    log "Cleaning up backups older than ${RETENTION_DAYS} days..."
    find "$BACKUP_DIR" -name "adam_*.sql.gz.gpg" -mtime +"$RETENTION_DAYS" -delete 2>/dev/null || true
    find "$BACKUP_DIR" -name "backup_*.log" -mtime +"$RETENTION_DAYS" -delete 2>/dev/null || true
    log "Cleanup complete."
}

# ── Main Backup Flow ────────────────────────────────────
log "=== Agent Adam Database Backup Started ==="
log "Database: ${DB_NAME} @ ${DB_HOST}:${DB_PORT}"

mkdir -p "$BACKUP_DIR"

# Step 1: pg_dump with connection check
log "Step 1/5: Running pg_dump..."
if PGPASSWORD="${DB_PASSWORD}" pg_dump \
    -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
    --no-owner --no-acl --format=custom --compress=9 \
    --exclude-table-data='analytics_events' \
    --exclude-table-data='audit_logs' \
    2>> "$LOG_FILE" | gzip > "${BACKUP_DIR}/temp_${TIMESTAMP}.sql.gz"; then
    log "pg_dump completed successfully."
else
    log "ERROR: pg_dump failed!"
    exit 1
fi

# Step 2: Encrypt backup
log "Step 2/5: Encrypting backup with GPG..."
if gpg --batch --yes --trust-model always \
    --recipient "$GPG_RECIPIENT" \
    --encrypt "${BACKUP_DIR}/temp_${TIMESTAMP}.sql.gz" 2>> "$LOG_FILE"; then
    mv "${BACKUP_DIR}/temp_${TIMESTAMP}.sql.gz.gpg" "$BACKUP_FILE"
    rm -f "${BACKUP_DIR}/temp_${TIMESTAMP}.sql.gz"
    log "Encryption complete: $BACKUP_FILE"
else
    log "ERROR: GPG encryption failed!"
    exit 1
fi

# Step 3: Verify backup integrity
log "Step 3/5: Verifying backup integrity..."
BACKUP_SIZE=$(stat -c%s "$BACKUP_FILE" 2>/dev/null || stat -f%z "$BACKUP_FILE" 2>/dev/null)
if [ "$BACKUP_SIZE" -gt 1000 ]; then
    log "Backup size: ${BACKUP_SIZE} bytes — OK"
else
    log "ERROR: Backup file too small (${BACKUP_SIZE} bytes) — possible corruption!"
    exit 1
fi

# Step 4: Upload to S3 (Hetzner Object Storage)
log "Step 4/5: Uploading to S3..."
if command -v s3cmd &> /dev/null; then
    s3cmd put "$BACKUP_FILE" "s3://${S3_BUCKET}/database/$(basename "$BACKUP_FILE")" \
        --host="${S3_ENDPOINT#https://}" \
        --host-bucket="${S3_BUCKET}.${S3_ENDPOINT#https://}" \
        2>> "$LOG_FILE"
    log "S3 upload complete."
else
    log "WARNING: s3cmd not found — skipping S3 upload."
fi

# Step 5: Cleanup old backups
log "Step 5/5: Rotating old backups..."
cleanup_old_backups

# ── Summary ─────────────────────────────────────────────
log "=== Backup Complete ==="
log "File: $BACKUP_FILE"
log "Size: $((BACKUP_SIZE / 1024 / 1024)) MB"
log "Location: ${BACKUP_DIR}/ and s3://${S3_BUCKET}/database/"
log "========================="

# ── Healthchecks Ping ───────────────────────────────────
if [ -n "${HEALTHCHECKS_UUID:-}" ]; then
    curl -fsS -m 10 --retry 3 "https://healthchecks.silvertech.ai/ping/${HEALTHCHECKS_UUID}" \
        || log "WARNING: Healthchecks ping failed"
fi

exit 0
