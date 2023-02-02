variable "region" {
    description = "Region in GCP for deploy server"
    default = "europe-west6"
  }
variable "mngt_key" {
    description = "Key for you servise account in GCP"
    default = ".\\prod-svc-creds.json"
  }
variable "project" {
    description = "Name of project in GCP"
    default = "pirate-project-374313"
  }
