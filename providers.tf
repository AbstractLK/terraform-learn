# optional for adding official providers in hashicorp registry

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.22.1"
    }
  }
}