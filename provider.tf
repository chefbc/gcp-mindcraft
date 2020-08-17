# Specify the provider (GCP, AWS, Azure)
provider "google" {
  credentials = file("~/.config/gcloud/terraform.json")
  project     = "chefbc"
  region      = "us-central1"
}

