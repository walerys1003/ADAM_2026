# ─────────────────────────────────────────────────────────────────
# Agent Adam — Terraform Variables
# SilverTech | June 2026
# ─────────────────────────────────────────────────────────────────

# ─── Required Variables ────────────────────────────────────────

variable "hcloud_token" {
  type        = string
  sensitive   = true
  description = "Hetzner Cloud API token for provisioning compute resources"
}

variable "cloudflare_api_token" {
  type        = string
  sensitive   = true
  description = "Cloudflare API token for DNS management and proxying"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare zone ID for silvertech.ai domain"
  default     = ""
}

variable "supabase_url" {
  type        = string
  sensitive   = true
  description = "Supabase project URL for edge functions and real-time"
  default     = ""
}

variable "supabase_anon_key" {
  type        = string
  sensitive   = true
  description = "Supabase anonymous key for public API access"
  default     = ""
}

variable "supabase_service_key" {
  type        = string
  sensitive   = true
  description = "Supabase service role key for admin operations"
  default     = ""
}

# ─── Environment ────────────────────────────────────────────────

variable "environment" {
  type        = string
  description = "Deployment environment (staging, production)"
  default     = "production"

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be 'staging' or 'production'."
  }
}

variable "project_name" {
  type        = string
  description = "Project name for resource naming"
  default     = "agent-adam"
}

# ─── SSH ────────────────────────────────────────────────────────

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key for server access"
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to SSH private key for provisioning"
  default     = "~/.ssh/id_ed25519"
  sensitive   = true
}

# ─── Admin Access ───────────────────────────────────────────────

variable "admin_ips" {
  type        = list(string)
  description = "List of admin IP addresses for SSH and monitoring access"
  default     = []
}

# ─── Compute ────────────────────────────────────────────────────

variable "api_server_type" {
  type        = string
  description = "Hetzner server type for API nodes"
  default     = "cpx31"
}

variable "worker_server_type" {
  type        = string
  description = "Hetzner server type for worker nodes"
  default     = "cpx21"
}

variable "api_server_count" {
  type        = number
  description = "Number of API server instances"
  default     = 1

  validation {
    condition     = var.api_server_count >= 1 && var.api_server_count <= 5
    error_message = "API server count must be between 1 and 5."
  }
}

variable "worker_server_count" {
  type        = number
  description = "Number of worker server instances"
  default     = 1
}

# ─── Storage ────────────────────────────────────────────────────

variable "backup_retention_days" {
  type        = number
  description = "Number of days to retain backups"
  default     = 30
}

# ─── Database ───────────────────────────────────────────────────

variable "postgres_version" {
  type        = string
  description = "PostgreSQL version with pgvector support"
  default     = "17"
}

variable "redis_version" {
  type        = string
  description = "Redis version for BullMQ and caching"
  default     = "7"
}

# ─── Monitoring ─────────────────────────────────────────────────

variable "enable_monitoring" {
  type        = bool
  description = "Enable Prometheus + Grafana monitoring stack"
  default     = true
}

variable "grafana_admin_password" {
  type        = string
  description = "Grafana admin password"
  sensitive   = true
  default     = ""
}

variable "alert_email" {
  type        = string
  description = "Email address for critical alerts"
  default     = "alerts@silvertech.ai"
}

# ─── Voice / AI ─────────────────────────────────────────────────

variable "deepgram_api_key" {
  type        = string
  description = "Deepgram Nova-3 API key for STT"
  sensitive   = true
  default     = ""
}

variable "gemini_api_key" {
  type        = string
  description = "Google Gemini API key for LLM"
  sensitive   = true
  default     = ""
}

variable "openai_api_key" {
  type        = string
  description = "OpenAI API key for TTS"
  sensitive   = true
  default     = ""
}

variable "twilio_account_sid" {
  type        = string
  description = "Twilio Account SID for voice calls"
  sensitive   = true
  default     = ""
}

variable "twilio_auth_token" {
  type        = string
  description = "Twilio Auth Token for voice calls"
  sensitive   = true
  default     = ""
}

# ─── Email ──────────────────────────────────────────────────────

variable "sendgrid_api_key" {
  type        = string
  description = "SendGrid API key for transactional emails"
  sensitive   = true
  default     = ""
}

# ─── Package Pricing ────────────────────────────────────────────

variable "package_pricing_pln" {
  type = map(number)
  description = "Package pricing in PLN per month"
  default = {
    KONTAKT  = 99
    ZDROWIE  = 199
    AKTYWNY  = 299
  }
}

# ─── RODO / GDPR ───────────────────────────────────────────────

variable "data_retention_days" {
  type        = number
  description = "Maximum days to retain personal data per GDPR"
  default     = 365

  validation {
    condition     = var.data_retention_days >= 30 && var.data_retention_days <= 730
    error_message = "Data retention must be between 30 and 730 days."
  }
}

variable "gdpr_region" {
  type        = string
  description = "GDPR-compliant region for data storage"
  default     = "eu-central-1"
}

# ─── Feature Flags ──────────────────────────────────────────────

variable "features" {
  type = map(bool)
  description = "Feature flags for gradual rollout"
  default = {
    voice_websocket    = true
    rag_retrieval      = true
    guardrails_pipeline = true
    cost_tracking      = true
    health_connect     = true
    marketplace        = true
    sos_escalation     = true
    weekly_reports     = true
    push_notifications = true
    sms_alerts         = true
    email_digest       = true
  }
}
