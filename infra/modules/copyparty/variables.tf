variable "network_id" {
  type = string
}

variable "share_folder" {
  description = "Host path to folder to be shared to copyparty"
  type        = string
}

variable "share_folder_path_in_container" {
  type    = string
  default = "/share"
}

variable "conf_path" {
  description = "Host path to conf used for copyparty to setup share"
  type        = string
}

variable "domain" {
  type = string
}

variable "internal_port" {
  description = "Internal share HTTP port"
  type        = number
  default     = 3923
}

variable "exposed_port" {
  description = "External nginx HTTP port exposed for local machine (HTTP only)"
  type        = number
  default     = 80
}

variable "certs_path" {
  description = "Host path containing fullchain.pem and privkey.pem for nginx TLS"
  type        = string
  default     = "/opt/nginx/certs"
}

