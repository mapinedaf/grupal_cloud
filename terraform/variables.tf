variable "aws_region"{
    type = string
    description ="Region donde se crean los recursos"
    default = "us-east-1"
}

    variable "s3_bucket_name"{
    type = string
    description ="Nombre del bucket s3"
}

variable "instance_type"{
    type = string
    description ="tipo/tamaño de la instancia ec2"
    default = "t3.micro"
}

variable "owner_tag"{
    type = string
    description ="tag owner para identificar el recurso "
    default = "alumno"
}