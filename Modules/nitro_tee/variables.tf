variable "region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m5.xlarge"
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "my-nitro-tee"
}

variable "github_token" {
  description = "GitHub personal access token for private repo access"
  type        = string
  sensitive   = true
}
