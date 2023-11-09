terraform {
  required_version = ">=1.6.0, < 2.0.0"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# provider
provider "aws" {
  region  = "ap-northeast-2" #Asia Pacific (Seoul)
}