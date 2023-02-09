provider "google"{
    credentials = var.mngt_key
    project     = var.project
    region      = var.region
}

resource "google_compute_instance_template" "web-server-template" {
  name = "web-server-template"
  machine_type = "e2-micro"
  disk {
    source_image = "debian-cloud/debian-10"
  }
  network_interface {
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.default.id
    access_config {
      nat_ip = null
      }
  }

  metadata = {
     startup-script = <<-EOF
      #! /bin/bash
      set -euo pipefail

      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install apache2 -y
      rm -rf /var/www/html/index.html
      mkdir /home/admin
      apt install -y git
      git init /home/admin/
      git clone https://github.com/AnnaConda007/testForAlex.git /home/admin/testForAlex
      mv /home/admin/testForAlex/* /var/www/html/

    EOF
  }
  tags = ["webserver"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "web-instance-group-manager" {
  name = "web-instance-group-manager"
  zone = var.zone
  base_instance_name = "web-instance"
  
  named_port {
    name = "http"
    port = 80
  }
  version {
    instance_template = google_compute_instance_template.web-server-template.id
}
  target_size = 2
}


# VPC
resource "google_compute_network" "default" {
  name                    = "def-net"
    auto_create_subnetworks = false
}
# backend subnet
resource "google_compute_subnetwork" "default" {
  name          = "def-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.default.id
}

# reserved IP address
resource "google_compute_global_address" "default" {
  name     = "def-static-ip"
}
#########################################

##For test
resource "google_compute_firewall" "webserverrule" {
    name    = "webserver"
    network = "default"
    allow {
        protocol = "tcp"
        ports    = ["80","443"]
    }
    source_ranges = ["0.0.0.0/0"] 
    target_tags   = ["webserver"]
}

#resource "google_compute_address" "static" {
#  name = "ipv4-address"
#}