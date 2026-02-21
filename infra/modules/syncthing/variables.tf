variable "network_id" {
  type = string
}

variable "sync_folder" {
  type = string
}

variable "config_folder" {
  type    = string
  default = "/opt/syncthing/config"
}

variable "puid" {
  description = "User ID to run Syncthing as (match your host user for file ownership)"
  type        = number
  default     = 1000
}

variable "pgid" {
  description = "Group ID"
  type        = number
  default     = 1000
}

variable "web_ui_port" {
  description = "Port for serving web-ui on"
  type        = number
  default     = 83884
}

