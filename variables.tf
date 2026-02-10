variable "aws_region" {
  type        = string
  description = "Region donde se crean los recursos"
  default     = "us-east-1"
}

variable "ec2_instance_type" {
  type        = string
  description = "Tipo/tamaño de la instancia EC2"
  default     = "t3.small"
}

variable "rds_instance_type" {
  type        = string
  description = "Tipo/tamaño de la instancia RDS"
  default     = "db.t3.micro"
}

variable "db_username" {
  type        = string
  description = "Usuario de base de datos PostgreSQL"
  default     = "postgres"
}

variable "db_password" {
  type        = string
  description = "Contraseña de base de datos PostgreSQL"
  sensitive   = true
}

variable "key_pair_name" {
  type        = string
  description = "Nombre del key pair para SSH (opcional)"
  default     = ""
}

variable "owner_tag" {
  type        = string
  description = "Tag owner para identificar el recurso"
  default     = "alumno"
}