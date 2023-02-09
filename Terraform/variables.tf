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
variable "install_web" {
  default="C:\\GIT\\Petproject1\\scripts\\install_web.sh"
  }
variable "install_site" {
  default = "C:\\GIT\\Petproject1\\scripts\\make_site.sh"
}
variable "zone" {
  default = "europe-west6-a"
  
}