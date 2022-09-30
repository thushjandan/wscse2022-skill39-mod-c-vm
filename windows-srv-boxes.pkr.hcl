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

locals {
    wsc_builds = {
        gui = {
            win1 = {
                ip = "10.22.0.101"
            }
            win4 = {
                ip = "10.22.0.104"
            }
        }
        core = {
            win2 = {
                ip = "10.22.0.102"
            }
            win3 = {
                ip = "10.22.0.103"
            }
            win5 = {
                ip = "10.22.0.105"
            }
        }
    }    
}

source "vmware-vmx" "wscse2022-win-clone-base" {
    source_path = "./output-wscse2022-win-srv-base/wscse2022-win-srv-base.vmx"
    linked = false
    format = "ovf"

    headless = true
    boot_wait = "2m"
    http_directory = "http"
    communicator = "winrm"
    winrm_timeout = "4h"
    winrm_username = "Administrator"
    winrm_password = "Incheon-2022"
}

source "vmware-vmx" "wscse2022-win-core-clone-base" {
    source_path = "./output-wscse2022-win-srv-core-base/wscse2022-win-srv-core-base.vmx"
    linked = false
    format = "ovf"

    headless = true
    boot_wait = "2m"
    http_directory = "http"
    communicator = "winrm"
    winrm_timeout = "4h"
    winrm_username = "Administrator"
    winrm_password = "Incheon-2022"
}

build {
    dynamic "source" {
        for_each = local.wsc_builds.gui
        labels = ["sources.vmware-vmx.wscse2022-win-clone-base"]
        content {
            name = source.key
            vm_name = upper(source.key)
            vmdk_name = lower(source.key)
            display_name = upper(source.key)
            output_directory = "output_wscse2022-${lower(source.key)}"
            shutdown_command = "shutdown /s /t 20 /f /d p:4:1 & netsh interface ipv4 set address name=\"Ethernet0\" source=static addr=${source.value.ip} mask=255.255.255.0"
        }
    }
    dynamic "source" {
        for_each = local.wsc_builds.core
        labels = ["sources.vmware-vmx.wscse2022-win-core-clone-base"]
        content {
            name = source.key
            vm_name = upper(source.key)
            vmdk_name = lower(source.key)
            display_name = upper(source.key)
            output_directory = "output_wscse2022-${lower(source.key)}"
            shutdown_command = "shutdown /s /t 20 /f /d p:4:1 & netsh interface ipv4 set address name=\"Ethernet0\" source=static addr=${source.value.ip} mask=255.255.255.0"
        }
    }

    provisioner "windows-shell" {
        inline = [
            "Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase",
            "\"C:\\Program Files\\VMware\\VMware Tools\\VMwareToolboxCmd\" disk shrink c:\\"
        ]
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