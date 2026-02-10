# Definir el cloud provider 
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
# Datos: VPC por defecto
# -----------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# -----------------------
# Security Group para EC2
# -----------------------
resource "aws_security_group" "ec2_sg" {
  name        = "shape-app-ec2-sg"
  description = "Security group for Shape API EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  # SSH 
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP acceso en puerto 6767
  ingress {
    description = "HTTP API 6767"
    from_port   = 6767
    to_port     = 6767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida a cualquier destino
  egress {
    description = "Outbound to internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "shape-app-ec2-sg"
    Project = "ShapeAPI"
  }
}

# Security Group para RDS
resource "aws_security_group" "rds_sg" {
  name        = "shape-app-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = data.aws_vpc.default.id

  # Permitir acceso desde EC2 security group
  ingress {
    description     = "PostgreSQL from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  tags = {
    Name    = "shape-app-rds-sg"
    Project = "ShapeAPI"
  }
}

# -----------------------
# RDS PostgreSQL
# -----------------------
resource "aws_db_instance" "postgres" {
  identifier           = "shape-db"
  db_name              = "shapedb"
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = var.rds_instance_type
  allocated_storage    = 20
  storage_type         = "gp2"
  storage_encrypted    = false
  
  # Credenciales
  username = var.db_username
  password = var.db_password
  
  # Configuración de red
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
  
  # Configuración adicional
  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
  
  # Configuración de mantenimiento
  maintenance_window      = "sun:03:00-sun:04:00"
  backup_window          = "02:00-03:00"
  backup_retention_period = 7
  
  # Configuración de performance
  max_allocated_storage = 100
  performance_insights_enabled = true
  
  tags = {
    Name    = "shape-postgres-db"
    Project = "ShapeAPI"
  }
}


# Subnet Group para RDS-
resource "aws_db_subnet_group" "default" {
  name       = "shape-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name    = "shape-db-subnet-group"
    Project = "ShapeAPI"
  }
}

# ################################
# EC2

resource "aws_instance" "shape_app" {
  # AMI de Amazon Linux 2023
  ami           = "ami-0532be01f26a3de55"
  instance_type = var.ec2_instance_type
  
  # Security Group
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  
  # Asignar IP pública
  associate_public_ip_address = true
  
  # Root volume
  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    delete_on_termination = true
  }
  
  # User data script para instalar y configurar la aplicación
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              
              # Instalar Java 21
              sudo yum install -y java-21-amazon-corretto-headless
              
              # Crear directorio para la aplicación
              sudo mkdir -p /opt/shape-app
              sudo chmod 755 /opt/shape-app
              
              # Descargar JAR desde GitHub
              cd /opt/shape-app
              sudo curl -L -o api-shapes.jar https://github.com/mapinedaf/grupal_cloud/releases/download/jar/api-shapes.jar
              
              # Crear script de inicio
              sudo cat > /etc/systemd/system/shape-app.service << 'SERVICE_EOF'
              [Unit]
              Description=Shape API Application
              After=network.target
              
              [Service]
              Type=simple
              User=ec2-user
              WorkingDirectory=/opt/shape-app
              ExecStart=/usr/bin/java -jar api-shapes.jar
              Restart=always
              RestartSec=10
              Environment="SPRING_DATASOURCE_URL=jdbc:postgresql://${aws_db_instance.postgres.endpoint}/shapedb"
              Environment="SPRING_DATASOURCE_USERNAME=${var.db_username}"
              Environment="SPRING_DATASOURCE_PASSWORD=${var.db_password}"
              Environment="SERVER_PORT=6767"
              Environment="SPRING_JPA_HIBERNATE_DDL_AUTO=update"
              
              [Install]
              WantedBy=multi-user.target
              SERVICE_EOF
              
              # Configurar permisos y habilitar servicio
              sudo chmod 644 /etc/systemd/system/shape-app.service
              sudo systemctl daemon-reload
              sudo systemctl enable shape-app.service
              sudo systemctl start shape-app.service
              
              # Verificar que el servicio está corriendo
              sudo systemctl status shape-app.service
              EOF
  
  user_data_replace_on_change = true
  
  tags = {
    Name    = "shape-api-server"
    Project = "ShapeAPI"
  }
}