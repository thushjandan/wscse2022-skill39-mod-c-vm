variable "win_srv_iso_path" {
    type = string
    default = "/data/ISO/SW_DVD9_Win_Server_STD_CORE_2019_1809.18_64Bit_English_DC_STD_MLF_X22-74330.ISO"
}

variable "win_srv_iso_checksum" {
    type = string
    default = "sha256:0067afe7fdc4e61f677bd8c35a209082aa917df9c117527fc4b2b52a447e89bb"
}


source "vmware-iso" "wscse2022-win-srv-base" {
    vm_name = "wscse2022-win-srv-base"
    vmdk_name = "win-srv-base"
    display_name = "WSCSE2022: Windows Server Base"
    
    version = 19

    iso_url = var.win_srv_iso_path
    iso_checksum = var.win_srv_iso_checksum

    guest_os_type = "windows9srv-64"
    cpus = 2
    memory = 2048
    disk_adapter_type = "lsisas1068"
    disk_size = 25600
    disk_type_id = 0

    boot_wait = "2m"
    communicator = "winrm"
    winrm_timeout = "4h"
    winrm_username = "Administrator"
    winrm_password = "Incheon-2022"

    headless = true

    http_directory = "http"
    floppy_files = [
        "./scripts/winsrv/Autounattend.xml",
        "./scripts/sysprep.bat",
        "./scripts/unattend.xml"
    ]
    shutdown_command = "a:/sysprep.bat"
    shutdown_timeout = "30m"
}

source "vmware-iso" "wscse2022-win-srv-core-base" {
    vm_name = "wscse2022-win-srv-core-base"
    vmdk_name = "win-srv-core-base"
    display_name = "WSCSE2022: Windows Server Core Base"
    
    version = 19

    iso_url = var.win_srv_iso_path
    iso_checksum = var.win_srv_iso_checksum

    guest_os_type = "windows9srv-64"
    cpus = 2
    memory = 4096
    disk_adapter_type = "lsisas1068"
    disk_size = 25600
    disk_type_id = 0

    boot_wait = "2m"
    communicator = "winrm"
    winrm_timeout = "4h"
    winrm_username = "Administrator"
    winrm_password = "Incheon-2022"

    headless = true

    http_directory = "http"
    floppy_files = [
        "./scripts/winsrv_core/Autounattend.xml",
        "./scripts/sysprep.bat",
        "./scripts/unattend.xml"
    ]
    shutdown_command = "a:/sysprep.bat"
    shutdown_timeout = "30m"
}

build {
    sources = [
        "sources.vmware-iso.wscse2022-win-srv-base",
        "sources.vmware-iso.wscse2022-win-srv-core-base"
    ]
    provisioner "powershell" {
        scripts = [
            "./scripts/install-vm-tools.ps1"
        ]
    }
}