variable "debian_iso_path" {
    type = string
    default = "/data/ISO/debian-11-3.0-amd64-BD-1.iso"
}

variable "debian_iso_checksum" {
    type = string
    default = "sha256:81778447f77a2e88847c85be6413862338fe609598bf09cb54faaaabf950011b"
}

source "vmware-iso" "wscse2022-debian-base" {
  vm_name = "wscse2022-debian-base"
  vmdk_name = "debian-base"
  display_name = "WSCSE2022: Debian Base"

  iso_url = var.debian_iso_path
  iso_checksum = var.debian_iso_checksum

  version = 19
  guest_os_type = "debian10-64"
  cpus = 2
  memory = 1024
  disk_size = 32768
  disk_type_id = 0

  headless = true
  http_directory = "http"
  ssh_username = "appadmin"
  ssh_password = "packer"
  ssh_timeout = "15m"
  boot_command = [
    "<esc><wait>",
    "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>",
  ]
  shutdown_command = "echo 'packer' | sudo -S /sbin/shutdown -h now"
}

build {
  sources = ["sources.vmware-iso.wscse2022-debian-base"]
}