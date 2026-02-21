output "syncthing_ui_url" {
  description = "Syncthing web UI (local)"
  value       = module.syncthing.url
}

output "n8n_ui_url" {
  description = "n8n web UI (local)"
  value       = module.n8n.url
}

output "pastebin_url" {
  description = "Pastebin local URL"
  value       = module.pastebin.url
}

output "share_url" {
  description = "Copyparty share web UI (local)"
  value       = module.copyparty.http_url
}

