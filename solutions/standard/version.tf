terraform {
  required_version = ">= 1.3.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.66.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.11.2"
    }
  }
}
