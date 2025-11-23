output "frontend_public_ip" {
  value       = aws_instance.frontend.public_ip
  description = "Public IP of the Frontend instance"
}

output "backend_public_ip" {
  value       = aws_instance.backend.public_ip
  description = "Public IP of the Backend instance"
}

output "db_endpoint" {
  value       = aws_db_instance.default.endpoint
  description = "The connection endpoint for the RDS database"
}

output "private_key_pem" {
  value       = tls_private_key.pk.private_key_pem
  sensitive   = true
  description = "Private key to access instances"
}
