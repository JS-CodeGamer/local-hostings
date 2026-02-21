terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

locals {
  nginx_conf = templatefile("nginx.conf.tpl", {
    domain       = var.domain
    host         = "share" # DNS name on the Docker network
    port         = var.internal_port
    exposed_port = var.exposed_port
  })
}

# Write the rendered nginx config to a temp file so it can be mounted
resource "local_file" "nginx_conf" {
  content  = local.nginx_conf
  filename = "${path.module}/.rendered/nginx.conf"
}

# ── share container ───────────────────────────────────────────────────────
resource "docker_image" "share" {
  name         = "copyparty/ac:latest"
  keep_locally = true
}

resource "docker_container" "share" {
  name  = "share"
  image = docker_image.share.image_id

  restart = "unless-stopped"

  # Not exposed directly to the host; nginx acts as the only ingress
  networks_advanced {
    name = var.network_id
  }

  # Mount the share folder
  volumes {
    host_path      = var.share_folder
    container_path = var.share_folder_path_in_container
    read_only      = false
  }

  # Mount the config file
  volumes {
    host_path      = var.conf_path
    container_path = "/etc/share/share.conf"
    read_only      = true
  }

  # Pass the config path as a CLI argument
  command = ["-c", "/etc/share/share.conf", "-p", var.internal_port]

  healthcheck {
    test         = ["CMD", "curl", "-f", "http://localhost:${var.internal_port}/"]
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

# ── nginx reverse proxy ───────────────────────────────────────────────────────
resource "docker_image" "share-reverse-proxy" {
  name         = "nginx:1.27-alpine"
  keep_locally = true
}

resource "docker_container" "nginx" {
  name  = "share_nginx"
  image = docker_image.share-reverse-proxy.image_id

  restart = "unless-stopped"

  ports {
    internal = var.exposed_port
    external = var.exposed_port
  }

  networks_advanced {
    name = var.network_id
        aliases = [var.domain]
  }

  volumes {
    host_path      = abspath(local_file.nginx_conf.filename)
    container_path = "/etc/nginx/conf.d/share.conf"
    read_only      = true
  }

  # TLS certs – for local dev use self-signed (setup.sh generates them).
  # For production, point nginx_certs_path at your real cert directory.
  volumes {
    host_path      = var.certs_path
    container_path = "/etc/nginx/certs"
    read_only      = true
  }

  # nginx needs share to be reachable on the shared network
  depends_on = [docker_container.share]

  log_driver = "json-file"
  log_opts = {
    max-size = "10m"
    max-file = "3"
  }
}

