# resource "google_compute_address" "static" {
#   name = "ipv4-address"
# }

# resource "google_compute_network" "default" {
#   name = "my-network"
# }

# resource "google_compute_subnetwork" "default" {
#   name          = "my-subnet"
#   ip_cidr_range = "10.0.0.0/20"
#   region        = "us-central1"
#   network       = google_compute_network.default.id
# }

# resource "google_compute_address" "internal_with_subnet_and_address" {
#   name         = "my-internal-address"
#   subnetwork   = google_compute_subnetwork.default.id
#   address_type = "INTERNAL"
#   address      = "10.0.0.5"
#   region       = "us-central1"
# }

resource "google_compute_address" "internal" {
  name         = "my-internal-address"
  subnetwork   = "default"
  address_type = "INTERNAL"
  address      = "10.128.0.5"
  region       = "us-central1"
}

resource "google_compute_instance" "default" {
  name         = "virtual-machine-from-terraform"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  service_account {
    email  = "compute-vm@chefbc.iam.gserviceaccount.com"
    scopes = ["datastore", "compute-rw", "service-control", "service-management", "logging-write", "monitoring-write", "trace-append", "storage-full", "userinfo-email"]
  }

  network_interface {
    network = "default"
    network_ip = google_compute_address.internal.address
    #access_config {
    #   nat_ip = google_compute_address.static.address
    #}
  }

  metadata_startup_script = "sudo apt-get update && sudo apt-get install apache2 -y && echo '<!doctype html><html><body><h1>Avenue Code is the leading software consulting agency focused on delivering end-to-end development solutions for digital transformation across every vertical. We pride ourselves on our technical acumen, our collaborative problem-solving ability, and the warm professionalism of our teams.!</h1></body></html>' | sudo tee /var/www/html/index.html"

  // Apply the firewall rule to allow external IPs to access this instance
  tags = ["http-server"]
}

resource "google_compute_firewall" "http-server" {
  name    = "default-allow-http-terraform"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

# output "ip" {
#   value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
# }

output "ip" {
  value = google_compute_instance.default.network_interface[0].network_ip
}

