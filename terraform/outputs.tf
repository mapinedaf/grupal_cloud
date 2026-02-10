output "bucket_name" {
  value       = aws_s3_bucket.demo.bucket
  description = "Nombre del bucket S3 creado"
}
 
output "ec2_public_ip" {
  value       = aws_instance.demo.public_ip
  description = "IP pública de la instancia EC2"
}
 