terraform {
  required_version = ">= 0.13"

  required_providers {
    external = {
      source  = "hashicorp/external"
      version = ">= 1.2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 0.6.0"
    }
  }
}
