output "id" {
  value = scaleway_vpc_public_gateway.this.id
}

output "ip" {
  value = scaleway_vpc_public_gateway_ip.this.address
}
