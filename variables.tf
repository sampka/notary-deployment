variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = "test"
}

variable "regions" {
  description = "List of AWS regions to deploy to"
  type        = list(string)
  default     = ["us-east-1", "eu-west-1"]
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}