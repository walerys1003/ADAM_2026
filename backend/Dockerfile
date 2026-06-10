# SilverTech Agent Adam — Production Dockerfile
# Multi-stage build optimized for Hetzner VPS deployment
# June 2026 — Node.js 22 LTS, pnpm, Prisma, BullMQ

# ── Stage 1: Builder ────────────────────────────────────
FROM node:22-alpine AS builder

RUN corepack enable && corepack prepare pnpm@9 --activate

WORKDIR /app

# Install dependencies first for layer caching
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod=false

# Copy source
COPY prisma ./prisma
COPY src ./src
COPY tsconfig.json ./

# Generate Prisma client
RUN npx prisma generate

# Build TypeScript
RUN pnpm run build || true  # Skip if no build step

# ── Stage 2: Production ─────────────────────────────────
FROM node:22-alpine AS production

RUN apk add --no-cache curl tini

# Create non-root user
RUN addgroup -g 1001 -S nodeapp && \
    adduser -S nodeapp -u 1001 -G nodeapp

WORKDIR /app

# Copy built assets from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
COPY --from=builder /app/pnpm-lock.yaml ./
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/src ./src

# Copy generated Prisma client
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma

# Create directories for logs and uploads
RUN mkdir -p /app/logs /app/uploads && \
    chown -R nodeapp:nodeapp /app

USER nodeapp

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

# Use tini as init for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "src/app.js"]

# Labels
LABEL org.opencontainers.image.title="Agent Adam Backend" \
      org.opencontainers.image.description="SilverTech Agent Adam — AI Voice Assistant for Seniors" \
      org.opencontainers.image.version="1.6.0" \
      org.opencontainers.image.vendor="SilverTech" \
      org.opencontainers.image.created="2026-06-01"
