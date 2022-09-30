variable "root_password" {
    type = string
    default = "Incheon-2022"
    sensitive = true
}

variable "admin_password" {
    type = string
    default = "Incheon-2022"
    sensitive = true
}

variable "debian_iso_path" {
    type = string
    default = "/data/ISO/debian-11-3.0-amd64-BD-1.iso"
}

locals {
    lin_vm_builds = {
        lin1 = {
            ip = "10.22.0.1"
        }
        lin2 = {
            ip = "10.22.0.2"
        }
        lin3 = {
            ip = "10.22.0.3"
        }
        lin4 = {
            ip = "10.22.0.4"
        }
        lin5 = {
            ip = "10.22.0.5"
        }
        host = {
            ip = "10.22.0.50"
        }
    }
    dev_vm_build = {
        dev-lin = {
            ip = "10.22.0.251"
        }
    }  
}

source "vmware-vmx" "wscse2022-clone-base" {
  source_path = "./output-wscse2022-debian-base/wscse2022-debian-base.vmx"
  linked = false
  format = "ovf"

  headless = true
  vmx_data = {
    "ide0:0.devicetype" = "cdrom-image"
    "ide0:0.filename" = "${var.debian_iso_path}"
  }
  http_directory = "http"
  ssh_username = "appadmin"
  ssh_password = "packer"
  ssh_timeout = "15m"
  shutdown_command = "echo '${var.admin_password}' | sudo -S /sbin/shutdown -h now"
}

build {
    dynamic "source" {
        for_each = local.lin_vm_builds
        labels = ["sources.vmware-vmx.wscse2022-clone-base"]
        content {
            name = source.key
            vm_name = upper(source.key)
            vmdk_name = lower(source.key)
            display_name = upper(source.key)
            output_directory = "output_wscse2022-${lower(source.key)}"
            vmx_data_post = {
                "ide0:0.clientdevice" = "TRUE"
                "ide0:0.devicetype" = "cdrom-raw"
                "ide0:0.filename" = "auto detect"
            }         
        }
    }

    dynamic "source" {
        for_each = local.dev_vm_build
        labels = ["sources.vmware-vmx.wscse2022-clone-base"]
        content {
            name = source.key
            vm_name = upper(source.key)
            vmdk_name = lower(source.key)
            display_name = upper(source.key)
            output_directory = "output_wscse2022-${lower(source.key)}"
            vmx_data_post = {
                "ide0:0.clientdevice" = "TRUE"
                "ide0:0.devicetype" = "cdrom-raw"
                "ide0:0.filename" = "auto detect"
                "memsize" = 4096
            }
        }
    }

    provisioner "shell" {
        only = ["vmware-vmx.host"]
        execute_command = "chmod +x {{ .Path }}; echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
        script = "./scripts/prepare-host-vm.sh"
    }

    provisioner "shell" {
        only = ["vmware-vmx.dev-lin"]
        execute_command = "chmod +x {{ .Path }}; echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
        script = "./scripts/prepare-dev-lin.sh"
    }

    provisioner "shell" {
        environment_vars = [
            "WSC_ROOT_PWD=${var.root_password}",
            "WSC_ADMIN_PWD=${var.admin_password}"
        ]
        execute_command = "chmod +x {{ .Path }}; echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
        script = "./scripts/change-pwd.sh"
    }

    provisioner "shell" {
        except = ["vmware-vmx.dev-lin"]
        environment_vars = [
            "WSC_IP=${local.lin_vm_builds[source.name].ip}"
        ]
        execute_command = "chmod +x {{ .Path }}; echo '${var.admin_password}' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
        script = "./scripts/change-network.sh"
    }

    provisioner "shell" {
        only = ["vmware-vmx.dev-lin"]
        environment_vars = [
            "WSC_IP=${local.dev_vm_build[source.name].ip}"
        ]
        execute_command = "chmod +x {{ .Path }}; echo '${var.admin_password}' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
        script = "./scripts/change-network.sh"
    }

    provisioner "shell" {
        inline = [
            "cat /dev/zero >zero.fill"
        ]
        valid_exit_codes = [0,1]
    }
    provisioner "shell" {
        inline = [
            "sleep 1",
            "sync",
            "/bin/rm -f zero.fill"
        ]
        valid_exit_codes = [0,1]
    }

    post-processors {
        post-processor "artifice" { # tell packer this is now the new artifact
            files = [
                "output_wscse2022-${source.name}/${upper(source.name)}.ovf",
                "output_wscse2022-${source.name}/${upper(source.name)}-disk1.vmdk",
                "output_wscse2022-${source.name}/${upper(source.name)}.nvram",
                "output_wscse2022-${source.name}/${upper(source.name)}.mf"
            ]
        }

        post-processor "checksum" {
            checksum_types = ["sha256"]
            output = "output_wscse2022-${source.name}/${upper(source.name)}.{{.ChecksumType}}.checksum"
        }

        post-processor "compress" {
            output = "export/wscse2022-module-c-${source.name}.tar.gz"
        }
    }

}