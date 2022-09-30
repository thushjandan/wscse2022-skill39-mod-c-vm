variable "win_10_iso_path" {
    type = string
    default = "/data/ISO/SW_DVD9_Win_Pro_10_21H2.7_64BIT_English_Pro_Ent_EDU_N_MLF_X23-15141.ISO"
}

variable "win_10_iso_checksum" {
    type = string
    default = "sha256:81778447f77a2e88847c85be6413862338fe609598bf09cb54faaaabf950011b"
}

source "vmware-iso" "wscse2022-win-10" {
    vm_name = "DEV-WIN"
    vmdk_name = "dev-win"
    display_name = "DEV-WIN"
    
    version = 19

    iso_url = var.win_10_iso_path
    iso_checksum = var.win_10_iso_checksum

    guest_os_type = "windows9-64"
    cpus = 2
    memory = 4096
    disk_adapter_type = "lsisas1068"
    disk_size = 30720
    disk_type_id = 0

    boot_wait = "2m"
    communicator = "winrm"
    winrm_timeout = "4h"
    winrm_username = "appadmin"
    winrm_password = "Incheon-2022"

    headless = true

    http_directory = "http"
    floppy_files = [
        "./scripts/win10/Autounattend.xml",
        "./scripts/win10/configure-winrm.ps1",
    ]
    output_directory = "output_wscse2022-dev-win"
    shutdown_command = "shutdown /s /t 20 /f /d p:4:1 & netsh interface ipv4 set address name=\"Ethernet0\" source=static addr=10.22.0.252 mask=255.255.255.0"
}

build {
    sources = [
        "sources.vmware-iso.wscse2022-win-10",
    ]
    provisioner "powershell" {
        scripts = [
            "./scripts/install-vm-tools.ps1",
            "./scripts/prepare-dev-win.ps1"
        ]
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
                "output_wscse2022-${source.name}/${upper(source.name)}.vmsd",
                "output_wscse2022-${source.name}/${upper(source.name)}.vmxf",
                "output_wscse2022-${source.name}/${upper(source.name)}.nvram",
                "output_wscse2022-${source.name}/${upper(source.name)}.mf"
            ]
        }

        post-processor "checksum" {
            checksum_types = ["sha256"]
            output = "output_wscse2022-${source.name}/${upper(source.name)}.{{.ChecksumType}}.checksum"
        }

        post-processor "compress" {
            output = "export/wscse2022-module-c-${source.name}.zip"
        }
    }
}