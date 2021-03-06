terraform {
  backend "s3" {
    bucket  = "k2tf-web-state"
    key  = "terraform/k2tf-web-state"
    region = "ap-southeast-1"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

provider "aws" {
   region = "ap-southeast-1"
}

provider "cloudflare" {}