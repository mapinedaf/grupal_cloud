output "ec2_public_ip" {
  value       = aws_instance.shape_app.public_ip
  description = "IP pública de la instancia EC2"
}

output "ec2_public_dns" {
  value       = aws_instance.shape_app.public_dns
  description = "DNS público de la instancia EC2"
}

output "rds_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "Endpoint de conexión a RDS"
}

output "rds_port" {
  value       = aws_db_instance.postgres.port
  description = "Puerto de RDS"
}

output "db_name" {
  value       = aws_db_instance.postgres.db_name
  description = "Nombre de la base de datos"
}

output "application_url" {
  value       = "http://${aws_instance.shape_app.public_ip}:6767"
  description = "URL de la aplicación"
}

output "ssh_command" {
  value       = var.key_pair_name != "" ? "ssh -i ${var.key_pair_name}.pem ec2-user@${aws_instance.shape_app.public_ip}" : "Configure key_pair_name para SSH"
  description = "Comando SSH para conectarse a la instancia"
}