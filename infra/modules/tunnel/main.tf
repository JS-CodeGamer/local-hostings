terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "cloudflared" {
  name         = "cloudflare/cloudflared:latest"
  keep_locally = true
}

resource "docker_container" "tunnel" {
  name  = "cloudflare_tunnel"
  image = docker_image.cloudflared.image_id

  restart = "unless-stopped"

  command = ["tunnel", "--no-autoupdate", "run", "--token", var.tunnel_token]

  networks_advanced {
    name = var.network_id
  }

  # No ports exposed — cloudflared connects outbound to Cloudflare's edge
  # and routes inbound traffic to services on the shared Docker network.

  log_driver = "json-file"
  log_opts = {
    max-size = "10m"
    max-file = "3"
  }
}

