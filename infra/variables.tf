variable "docker_host" {
  description = "Docker daemon socket"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

# ── Pastebin ──────────────────────────────────────────────────────────────────
variable "pastebin_source" {
  description = "Absolute path to the ./pastebin directory containing the Rust source"
  type        = string
}

variable "pastebin_port" {
  type = number
}

# ── Copyparty / NAS ───────────────────────────────────────────────────────────
variable "share_folder_path" {
  description = "Host path of the share / NAS folder to mount"
  type        = string
}

variable "docker_container_share_folder" {
  description = "Mount point inside the copyparty container"
  type        = string
  default     = "/share"
}

variable "copyparty_conf_path" {
  description = "Absolute path to ./copyparty/share.conf on the host"
  type        = string
}

variable "share_domain" {
  description = "Public domain name for share service"
  type        = string
}

variable "share_certs_path" {
  description = "Host path containing TLS certs for nginx (fullchain.pem + privkey.pem)"
  type        = string
}

variable "share_exposed_port" {
  type = number
}

# ── Tunnel ────────────────────────────────────────────────────────────────────
variable "tunnel_token" {
  description = "Cloudflare Tunnel token (keep this secret)"
  type        = string
  sensitive   = true
}

# ── Syncthing ─────────────────────────────────────────────────────────────────
variable "sync_folder" {
  description = "Host path for the folder Syncthing should sync"
  type        = string
}

variable "syncthing_config_folder" {
  description = "Host path where Syncthing stores its config / database"
  type        = string
}

variable "syncthing_web_ui_port" {
  description = "Port for serving web-ui for syncthing"
  type        = number
}

# ── n8n ───────────────────────────────────────────────────────────────────────
variable "n8n_data_path" {
  description = "Host path for n8n persistent data"
  type        = string
}

variable "n8n_port" {
  type = number
}


variable "n8n_encryption_key" {
  type = string
}


