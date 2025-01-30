provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu_west_1"
  region = "eu-west-1"
}

module "nitro_us_east_1" {
  source = "./modules/nitro_tee"
  providers = {
    aws = aws.us_east_1
  }
  region       = "us-east-1"
  key_name     = var.key_name
  instance_name = "nitro-tee-us-east-1"
  github_token = var.github_token  
}

module "nitro_eu_west_1" {
  source = "./Modules/nitro_tee"
  providers = {
    aws = aws.eu_west_1
  }
  region       = "eu-west-1"
  key_name     = var.key_name
  instance_name = "nitro-tee-eu-west-1"
  github_token = var.github_token  
}

