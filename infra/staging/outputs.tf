output "instance_ip" {
  value = google_compute_instance.staging.network_interface[0].access_config[0].nat_ip
}

output "boot_disk_name" {
  value = google_compute_instance.staging.boot_disk[0].device_name
}