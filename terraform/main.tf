#definir el cloud provider 
# Reglas mínimas: versión de Terraform y el provider AWS
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
# Provider: le dice a Terraform que trabajará con AWS y en qué región
provider "aws" {
  region = var.aws_region
}

# -----------------------
# Recurso 1: S3 Bucket
# -----------------------
resource "aws_s3_bucket" "demo" {
  bucket = var.s3_bucket_name

  tags = {
    Project      = "TerraformTaller"
    Propiertario = var.owner_tag
  }

}

# -----------------------
# Datos: VPC por defecto
# -----------------------
# data = "leer" información existente en AWS
# aquí le pedimos a AWS la VPC default para poder crear el Security Group
data "aws_vpc" "default" {
  default = true
}


# -----------------------
# Recurso 2: Security Group
# -----------------------
resource "aws_security_group" "ssh_open" {
  name        = "tf-taller-ssh-open"
  description = "SSH abierto para taller (NO recomendado en produccion)"
  vpc_id      = data.aws_vpc.default.id
 
  # Entrada (INBOUND): permitir SSH desde cualquier IP
  ingress {
    description = "SSH desde cualquier IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida (OUTBOUND): permitir salida a cualquier destino
  egress {
    description = "Salida a internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = {
    Project = "TerraformTaller"
  }
}

# -----------------------
# Recurso: EC2 Instance (versión simple)
# -----------------------
resource "aws_instance" "demo" {
  # AMI fija de Amazon Linux 2023 (us-east-1)
  ami = "ami-0532be01f26a3de55"
 
  # Tipo de instancia
  instance_type = var.instance_type
 
  # Security Group previamente creado
  vpc_security_group_ids = [aws_security_group.ssh_open.id]
 
  # Asignar IP pública automáticamente
  associate_public_ip_address = true
 
  tags = {
    Name    = "tf-taller-ec2"
    Project = "TerraformTaller"
  }
}