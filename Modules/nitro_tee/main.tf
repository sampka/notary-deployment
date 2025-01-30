data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-kernel-5.10-hvm-x86_64-gp2"
}

resource "aws_security_group" "nitro_sg" {
  name        = "nitro-enclave-sg"
  description = "Security group for Nitro Enclave EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nitro-enclave-sg"
  }
}

resource "aws_instance" "nitro_tee" {
  ami           = data.aws_ssm_parameter.ami.value
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.nitro_sg.id]

  enclave_options {
    enabled = true
  }


  root_block_device {
    volume_size = 32  # Set root volume to 32GB
    volume_type = "gp2"
    encrypted   = true
  }

  tags = {
    Name = var.instance_name
  }

  # Use cloud-init directives and fix execution context
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    GITHUB_TOKEN = var.github_token  # Match exact variable name used in user_data.sh
  }))

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}