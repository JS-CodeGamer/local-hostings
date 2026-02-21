terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "n8n" {
  name         = "n8nio/n8n:latest"
  keep_locally = true
}

resource "docker_container" "n8n" {
  name  = "n8n"
  image = docker_image.n8n.image_id

  restart = "unless-stopped"

  env = [
    "N8N_PORT=${var.port}",
    "N8N_ENCRYPTION_KEY=${var.encryption_key}",
    "N8N_RUNNERS_ENABLED=true",

    # Timezone – adjust to yours
    "GENERIC_TIMEZONE=UTC",
    "TZ=UTC",

    # Persist workflows and credentials
    "N8N_USER_FOLDER=/home/node/.n8n",

    # If you expose n8n via Cloudflare Tunnel, set this so webhooks work
    var.webhook_url != "" ? "WEBHOOK_URL=${var.webhook_url}" : "WEBHOOK_URL=http://localhost:${var.port}/",

    # Basic auth (optional — remove if you handle auth at the tunnel/network level)
    # "N8N_BASIC_AUTH_ACTIVE=true",
    # "N8N_BASIC_AUTH_USER=admin",
    # "N8N_BASIC_AUTH_PASSWORD=changeme",
  ]

  ports {
    internal = var.port
    external = var.port
  }

  volumes {
    host_path      = var.data_path
    container_path = "/home/node/.n8n"
  }

  networks_advanced {
    name = var.network_id
  }

  healthcheck {
    test         = ["CMD", "wget", "-qO-", "http://localhost:${var.port}/healthz"]
    interval     = "30s"
    timeout      = "5s"
    retries      = 3
    start_period = "20s"
  }

  log_driver = "json-file"
  log_opts = {
    max-size = "10m"
    max-file = "3"
  }
}

