output "instance_ip" {
  value = google_compute_instance.production.network_interface[0].access_config[0].nat_ip
}

output "boot_disk_name" {
  value = google_compute_instance.production.name
}