# TLS resources for generating a self-signed wildcard certificate for ingress to the AKS cluster
# Generate Private Key
resource "tls_private_key" "gateway_cert" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Generate the Self-Signed Certificate
resource "tls_self_signed_cert" "wildcard" {
  private_key_pem = tls_private_key.gateway_cert.private_key_pem

  subject {
    common_name  = "*.getshifting.com"
    organization = "GetShifting"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# Save the certificate locally
resource "local_file" "tls_cert" {
  content  = tls_self_signed_cert.wildcard.cert_pem
  filename = var.tls_cert_path
}
