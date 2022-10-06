# Packer project to build WSCSE 2022 Module C VMs
This project hosts the packer definition file to build OVF VM-images for the WSC Module C in Skill 39. For every VM there will be a `output*` folder, where you can find the OVF & VMDK files after build. In the `export` folder you can find the the VM images in a compressed format.

## Install Packer
[Install Packer](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli)

## Build
1. Configure all the required variables, like the path of the ISO files, in config.pkrvars.hcl
```
vim config.pkrvars.hcl
```
2. Build the base debian image
```
packer build -var-file=config.pkrvars.hcl base-debian.pkr.hcl
```
3. Build all the Debian VMs in parallel from the base image
```
packer build -var-file=config.pkrvars.hcl debian-boxes.pkr.hcl
# If only a single Debian VM needs to be build. e.g. HOST VM
# packer build -var-file=config.pkrvars.hcl -only=vmware-vmx.host debian-boxes.pkr.hcl
# If only a single Debian VM needs to be build. e.g. DEV-LIN
# packer build -var-file=config.pkrvars.hcl -only=vmware-vmx.dev-lin debian-boxes.pkr.hcl
```
4. Build the base Windows Server images
```
packer build -var-file=config.pkrvars.hcl base-windows-server.pkr.hcl
```
5. Build all the Windows Server images from the base image in parallel
```
packer build -var-file=config.pkrvars.hcl windows-srv-boxes.pkr.hcl
```
6. Build the Windos 10 VM
```
packer build -var-file=config.pkrvars.hcl windows-10-boxes.pkr.hcl
```
