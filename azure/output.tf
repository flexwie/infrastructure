output "dns_server" {
  value       = azurerm_dns_zone.dns.name_servers
  description = "The DNS servers for the created DNS zone"
}
