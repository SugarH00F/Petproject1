##VRSION TERRAFORM
terraform {
    required_version = "1.3.7"
}
##Provider
provider "google"{
    credentials = var.mngt_key
    project     = var.project
    region      = var.region
}
resource "google_compute_instance_template" "websrv" {
    name = "web-server-template"
    machine_type = "f1-micro"
###IMAGE FOR DEPLOE
    disk {
       source_image = data.google_compute_image.Debian11.self_link
    }
    network_interface {
        network = "default"
  }
##USER SSH KEY
    metadata = {
        ssh-keys = "admin:${file("~/.ssh/id_rsa.pub")}"
    }
    connection {
        type        = "ssh"
        user        = "admin"
        timeout     = "10s"
        host        = "${google_compute_instance_template.websrv.network_interface.0.access_config.0.nat_ip}"
        agent       = false
        private_key = "${file("~/.ssh/id_rsa")}"
  }

### SCRIPTS IN TO VM
    provisioner "remote-exec" {
        script = "C:\\GIT\\Petproject1\\scripts\\install_web.sh"
    }

    provisioner "remote-exec" {
        script = "C:\\GIT\\Petproject1\\scripts\\make_site.sh"


}
}

###BALANSER
resource "google_compute_instance_group" "instance-group" {
  name = "web-server-group"
  instance_template = google_compute_instance_template.websrv.self_link
  size = 2
  zone = "us-central1-a"
}
resource "google_compute_global_address" "load-balancer-ip" {
  name = "web-load-balancer-ip"
}
resource "google_compute_health_check" "health-check" {
  name = "web-load-balancer-health-check"
  tcp_health_check {
    port = "80"
  }
}
resource "google_compute_target_pool" "target-pool" {
  name = "web-load-balancer-target-pool"
  instances = [
    google_compute_instance_group.instance-group.self_link
  ]
  health_checks = [
    google_compute_health_check.health-check.self_link
  ]
}

###FIREWALL
resource "google_compute_forwarding_rule" "forwarding-rule" {
  name = "web-load-balancer-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address = google_compute_global_address.load-balancer-ip.address
  port_range = "80"
  target = google_compute_target_pool.target-pool.self_link
}

resource "google_compute_firewall" "firewall" {
    name    = "externalssh"
    network = "default"
    allow {
        protocol = "tcp"
        ports    = ["22"]
    }
    source_ranges = ["0.0.0.0/0"] 
    target_tags   = ["externalssh"]
}
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