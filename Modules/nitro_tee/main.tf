data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-kernel-5.10-hvm-x86_64-gp2"
}

resource "aws_security_group" "nitro_sg" {
  name        = "nitro-enclave-sg-${var.instance_name}"
  description = "Security group for Nitro Enclave EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 7047
    to_port     = 7047
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
    Name = "nitro-enclave-sg-${var.instance_name}"
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

  tags = {
    Name = var.instance_name
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    GITHUB_TOKEN = var.github_token  
  }))
}

# Network Load Balancer
resource "aws_lb" "nlb" {
  name               = "nlb-${var.instance_name}"
  internal           = false
  load_balancer_type = "network"
  subnets            = data.aws_subnets.default.ids

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "nlb-${var.instance_name}"
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "tg-${var.instance_name}"
  port        = 7047
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    protocol            = "HTTPS"
    path                = "/healthcheck"
    matcher             = "200"
    port                = 7047
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 7047
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.nitro_tee.id
  port             = 7047
}