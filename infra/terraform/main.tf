# SilverTech Agent Adam — Terraform Configuration
# Hetzner Cloud + Cloudflare + Supabase
# June 2026 — Production Infrastructure

terraform {
  required_version = ">= 1.8"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.48"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.40"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "s3" {
    # Using Hetzner Object Storage as backend
    # Configure via environment variables
    bucket = "silvertech-terraform-state"
    key    = "agent-adam/production/terraform.tfstate"
    region = "eu-central-1"
    endpoints = {
      s3 = "https://fsn1.your-objectstorage.com"
    }
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
  }
}

# ── Provider Config ─────────────────────────────────────
provider "hcloud" {
  token = var.hcloud_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# ── Variables ────────────────────────────────────────────
variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "environment" {
  type    = string
  default = "production"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

# ── SSH Key ──────────────────────────────────────────────
resource "hcloud_ssh_key" "default" {
  name       = "agent-adam-${var.environment}"
  public_key = file(var.ssh_public_key_path)
}

# ── Network ─────────────────────────────────────────────
resource "hcloud_network" "main" {
  name     = "adam-network-${var.environment}"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "backend" {
  network_id   = hcloud_network.main.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

# ── Firewall ────────────────────────────────────────────
resource "hcloud_firewall" "api" {
  name = "adam-api-fw-${var.environment}"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = var.admin_ips
    description = "SSH (admin only)"
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0"]
    description = "HTTP"
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "3000"
    source_ips = ["0.0.0.0/0"]
    description = "API (proxied)"
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "9090"
    source_ips = var.admin_ips
    description = "Prometheus (admin only)"
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "3001"
    source_ips = var.admin_ips
    description = "Grafana (admin only)"
  }
}

# ── Compute Instances ───────────────────────────────────
# Primary API server
resource "hcloud_server" "api" {
  name        = "adam-api-${var.environment}"
  image       = "ubuntu-24.04"
  server_type = "cpx31"  # 4 vCPU, 8 GB RAM, 80 GB NVMe — ~€20/mo
  datacenter  = "fsn1-dc14"  # Falkenstein, Germany
  location    = "fsn1"

  ssh_keys    = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.api.id]

  network {
    network_id = hcloud_network.main.id
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  labels = {
    environment = var.environment
    role        = "api"
    managed_by  = "terraform"
  }

  # Cloud-init for automated setup
  user_data = templatefile("${path.module}/cloud-init-api.yml", {
    environment = var.environment
    docker_compose_version = "2.27"
  })
}

# Worker node (background jobs)
resource "hcloud_server" "worker" {
  name        = "adam-worker-${var.environment}"
  image       = "ubuntu-24.04"
  server_type = "cpx21"  # 2 vCPU, 4 GB RAM
  datacenter  = "fsn1-dc14"
  location    = "fsn1"

  ssh_keys    = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.api.id]

  network {
    network_id = hcloud_network.main.id
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  labels = {
    environment = var.environment
    role        = "worker"
    managed_by  = "terraform"
  }
}

# ── Floating IP (for failover) ──────────────────────────
resource "hcloud_floating_ip" "api" {
  type          = "ipv4"
  home_location = "fsn1"
  description   = "Agent Adam API Floating IP"
}

resource "hcloud_floating_ip_assignment" "api" {
  floating_ip_id = hcloud_floating_ip.api.id
  server_id      = hcloud_server.api.id
}

# ── DNS (Cloudflare) ────────────────────────────────────
resource "cloudflare_record" "api" {
  zone_id = var.cloudflare_zone_id
  name    = "api"
  value   = hcloud_floating_ip.api.ip_address
  type    = "A"
  proxied = true
  ttl     = 1
}

resource "cloudflare_record" "admin" {
  zone_id = var.cloudflare_zone_id
  name    = "admin"
  value   = hcloud_floating_ip.api.ip_address
  type    = "A"
  proxied = true
  ttl     = 1
}

resource "cloudflare_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  value   = hcloud_floating_ip.api.ip_address
  type    = "A"
  proxied = true
  ttl     = 1
}

# ── Outputs ─────────────────────────────────────────────
output "api_ip" {
  value       = hcloud_floating_ip.api.ip_address
  description = "API server public IPv4"
}

output "api_domain" {
  value       = "https://api.silvertech.ai"
  description = "API endpoint URL"
}

output "grafana_url" {
  value       = "https://admin.silvertech.ai:3001"
  description = "Grafana dashboard URL"
}
