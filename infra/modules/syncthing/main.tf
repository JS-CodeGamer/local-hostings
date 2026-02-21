terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "syncthing" {
  name         = "lscr.io/linuxserver/syncthing:latest"
  keep_locally = true
}

resource "docker_container" "syncthing" {
  name  = "syncthing"
  image = docker_image.syncthing.image_id

  restart = "unless-stopped"

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "TZ=UTC",
  ]

  # Web UI
  ports {
    internal = 8384
    external = var.web_ui_port
  }

  # Sync protocol (TCP)
  ports {
    internal = 22000
    external = 22000
    protocol = "tcp"
  }

  # Sync protocol (QUIC/UDP)
  ports {
    internal = 22000
    external = 22000
    protocol = "udp"
  }

  # Local discovery
  ports {
    internal = 21027
    external = 21027
    protocol = "udp"
  }

  volumes {
    host_path      = var.config_folder
    container_path = "/config"
  }

  volumes {
    host_path      = var.sync_folder
    container_path = "/data"
  }

  networks_advanced {
    name = var.network_id
  }

  healthcheck {
    test         = ["CMD", "curl", "-f", "http://localhost:8384/rest/noauth/health"]
    interval     = "30s"
    timeout      = "5s"
    retries      = 3
    start_period = "15s"
  }

  log_driver = "json-file"
  log_opts = {
    max-size = "10m"
    max-file = "3"
  }
}

