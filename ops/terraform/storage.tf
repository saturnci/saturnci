resource "digitalocean_spaces_bucket" "storage" {
  name   = "saturnci-production-storage"
  region = "nyc3"
  acl    = "private"
}

output "storage_endpoint" {
  value = digitalocean_spaces_bucket.storage.bucket_domain_name
}
