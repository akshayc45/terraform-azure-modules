output "vm_priate_key" {
  value = tls_private_key.rsa[0].private_key_pem
}
