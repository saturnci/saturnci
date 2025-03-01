terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_database_cluster" "postgres" {
  name       = "saturnci-production-db-2025-02-28a"
  engine     = "pg"
  version    = "15"
  size       = "db-s-1vcpu-1gb"
  region     = "nyc1"
  node_count = 1
}

resource "digitalocean_database_cluster" "postgres_cache" {
  name       = "saturnci-production-db-cache"
  engine     = "pg"
  version    = "15"
  size       = "db-s-1vcpu-1gb"
  region     = "nyc1"
  node_count = 1
}

variable "do_token" {}

output "db_uri" {
  value = digitalocean_database_cluster.postgres.uri
  sensitive = true
}

output "cache_db_uri" {
  value = digitalocean_database_cluster.postgres_cache.uri
  sensitive = true
}
