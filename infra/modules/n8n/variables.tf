variable "network_id" {
  type = string
}

variable "data_path" {
  type = string
}

variable "port" {
  type    = number
  default = 5678
}

variable "encryption_key" {
  description = "Secret key used to encrypt credentials stored by n8n. Set via TF_VAR_n8n_encryption_key."
  type        = string
  sensitive   = true
}

variable "webhook_url" {
  description = "Public URL where n8n webhooks are reachable (via Cloudflare Tunnel)"
  type        = string
  default     = ""
}

