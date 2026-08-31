# My public key
resource "scaleway_iam_ssh_key" "sjoerd" {
  name       = "sjoerd"
  public_key = var.public_key
}
