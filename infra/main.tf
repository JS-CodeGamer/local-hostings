terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = var.docker_host
}

# ── Shared network ────────────────────────────────────────────────────────────
resource "docker_network" "infra" {
  name   = "infra_net"
  driver = "bridge"
}

# ── Modules ───────────────────────────────────────────────────────────────────
module "pastebin" {
  source = "./modules/pastebin"

  network_id = docker_network.infra.id
  source_dir = var.pastebin_source
  port       = var.pastebin_port
}

module "copyparty" {
  source = "./modules/copyparty"

  network_id                     = docker_network.infra.id
  share_folder                   = var.share_folder_path
  share_folder_path_in_container = var.docker_container_share_folder
  conf_path                      = var.copyparty_conf_path
  domain                         = var.share_domain
  certs_path                     = var.share_certs_path
  exposed_port                   = var.share_exposed_port
}

module "tunnel" {
  source = "./modules/tunnel"

  network_id   = docker_network.infra.id
  tunnel_token = var.tunnel_token
}

module "syncthing" {
  source = "./modules/syncthing"

  network_id    = docker_network.infra.id
  sync_folder   = var.sync_folder
  config_folder = var.syncthing_config_folder
  web_ui_port   = var.syncthing_web_ui_port
}

module "n8n" {
  source = "./modules/n8n"

  network_id     = docker_network.infra.id
  data_path      = var.n8n_data_path
  port           = var.n8n_port
  encryption_key = var.n8n_encryption_key
}


