terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}


# Build the Docker image from the local Rust source directory.
# Terraform will rebuild the image whenever the Dockerfile changes
# (tracked via the sha256 of its content).
resource "docker_image" "pastebin" {
  name = "pastebin:local"

  build {
    context    = var.source_dir
    dockerfile = "Dockerfile"

    # Force rebuild when Dockerfile content changes
    build_args = {}
  }

  # Keep the image around when the container is destroyed so the next
  # `apply` is fast (no full recompile).
  keep_locally = true

  triggers = {
    dockerfile_sha = filesha256("${var.source_dir}/Dockerfile")
    # Uncomment to also trigger on any src/ change (can be slow on large trees):
    # src_sha = sha256(join("", [for f in fileset(var.source_dir, "src/**") : filesha256("${var.source_dir}/${f}")]))
  }
}

resource "docker_container" "pastebin" {
  name  = "pastebin"
  image = docker_image.pastebin.image_id

  restart = "unless-stopped"

  # Rocket default port; override via ROCKET_PORT env if needed
  ports {
    internal = 80
    external = var.port
  }

  networks_advanced {
    name = var.network_id
  }

  # Rocket reads Rocket.toml from its working directory; the Dockerfile
  # copies it in, so no extra mount is needed.

  healthcheck {
    test         = ["CMD", "curl", "-f", "http://localhost:8000/health"]
    interval     = "30s"
    timeout      = "5s"
    retries      = 3
    start_period = "10s"
  }

  log_driver = "json-file"
  log_opts = {
    max-size = "10m"
    max-file = "3"
  }
}

