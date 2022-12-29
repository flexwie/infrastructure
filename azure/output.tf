output "dns_server" {
  value       = azurerm_dns_zone.dns.name_servers
  description = "The DNS servers for the created DNS zone"
}

output "workload_id" {
  value = azurerm_user_assigned_identity.workload.client_id
}

output "oidc_issuer" {
  value = azurerm_kubernetes_cluster.cluster.oidc_issuer_url
}
