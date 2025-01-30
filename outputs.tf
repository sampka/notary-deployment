output "us_east_nlb_dns" {
  value = module.nitro_us_east_1.nlb_dns_name
}

output "eu_west_nlb_dns" {
  value = module.nitro_eu_west_1.nlb_dns_name
}

output "ap_northeast_nlb_dns" {
  value = module.nitro_ap_northeast_1.nlb_dns_name
}

output "sa_east_nlb_dns" {
  value = module.nitro_sa_east_1.nlb_dns_name
}

output "route53_endpoint" {
  value = var.domain_name
}