variable "network_id" {
  type = string
}

variable "source_dir" {
  description = "Absolute path to pastebin Rust source directory"
  type        = string
}

variable "port" {
  description = "Port to expose pastebin on"
  type        = number
  default     = 80
}

