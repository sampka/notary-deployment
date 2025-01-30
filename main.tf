provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu_west_1"
  region = "eu-west-1"
}

provider "aws" {
  alias  = "ap_northeast_1"
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "sa_east_1"
  region = "sa-east-1"
}

data "aws_route53_zone" "primary" {
  name         = var.domain_name
  private_zone = false
}

module "nitro_us_east_1" {
  source = "./modules/nitro_tee"
  providers = {
    aws = aws.us_east_1
  }
  region        = "us-east-1"
  key_name      = var.key_name
  instance_name = "nitro-tee-us-east-1"
  domain_name   = var.domain_name
  github_token = var.github_token
}

module "nitro_eu_west_1" {
  source = "./modules/nitro_tee"
  providers = {
    aws = aws.eu_west_1
  }
  region        = "eu-west-1"
  key_name      = var.key_name
  instance_name = "nitro-tee-eu-west-1"
  domain_name   = var.domain_name
  github_token = var.github_token
}

module "nitro_ap_northeast_1" {
  source = "./modules/nitro_tee"
  providers = {
    aws = aws.ap_northeast_1
  }
  region        = "ap-northeast-1"
  key_name      = var.key_name
  instance_name = "nitro-tee-ap-northeast-1"
  domain_name   = var.domain_name
  github_token = var.github_token
}

module "nitro_sa_east_1" {
  source = "./modules/nitro_tee"
  providers = {
    aws = aws.sa_east_1
  }
  region        = "sa-east-1"
  key_name      = var.key_name
  instance_name = "nitro-tee-sa-east-1"
  domain_name   = var.domain_name
  github_token = var.github_token
}



# Health Checks
resource "aws_route53_health_check" "us_east" {
  fqdn              = module.nitro_us_east_1.nlb_dns_name
  port              = 7047
  type              = "HTTPS"
  resource_path     = "/healthcheck"
  request_interval  = 30
  failure_threshold = 3
  tags = {
    Name = "us-east-health-check"
  }
}

resource "aws_route53_health_check" "eu_west" {
  fqdn              = module.nitro_eu_west_1.nlb_dns_name
  port              = 7047
  type              = "HTTPS"
  resource_path     = "/healthcheck"
  request_interval  = 30
  failure_threshold = 3
  tags = {
    Name = "eu-west-health-check"
  }
}

resource "aws_route53_health_check" "ap_northeast" {
  fqdn              = module.nitro_ap_northeast_1.nlb_dns_name
  port              = 7047
  type              = "HTTPS"
  resource_path     = "/healthcheck"
  request_interval  = 30
  failure_threshold = 3
  tags = {
    Name = "ap-northeast-health-check"
  }
}

resource "aws_route53_health_check" "sa_east" {
  fqdn              = module.nitro_sa_east_1.nlb_dns_name
  port              = 7047
  type              = "HTTPS"
  resource_path     = "/healthcheck"
  request_interval  = 30
  failure_threshold = 3
  tags = {
    Name = "sa-east-health-check"
  }
}

# Route53 Geolocation Records
resource "aws_route53_record" "us_east" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  geolocation_routing_policy {
    continent = "NA"
  }

  set_identifier = "us-east-1"
  alias {
    name                   = module.nitro_us_east_1.nlb_dns_name
    zone_id                = module.nitro_us_east_1.nlb_zone_id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.us_east.id
}

resource "aws_route53_record" "eu_west" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  geolocation_routing_policy {
    continent = "EU"
  }

  set_identifier = "eu-west-1"
  alias {
    name                   = module.nitro_eu_west_1.nlb_dns_name
    zone_id                = module.nitro_eu_west_1.nlb_zone_id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.eu_west.id
}

resource "aws_route53_record" "ap_northeast" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  geolocation_routing_policy {
    continent = "AS"
  }

  set_identifier = "ap-northeast-1"
  alias {
    name                   = module.nitro_ap_northeast_1.nlb_dns_name
    zone_id                = module.nitro_ap_northeast_1.nlb_zone_id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.ap_northeast.id
}

resource "aws_route53_record" "sa_east" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  geolocation_routing_policy {
    continent = "SA"
  }

  set_identifier = "sa-east-1"
  alias {
    name                   = module.nitro_sa_east_1.nlb_dns_name
    zone_id                = module.nitro_sa_east_1.nlb_zone_id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.sa_east.id
}