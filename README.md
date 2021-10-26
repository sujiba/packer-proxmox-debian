# Debian 11 - build with Packer

### Overview
- [## Introduction](https://github.com/sujiba/packer-proxmox-debian#introduction)
- [## Prerequisites](https://github.com/sujiba/packer-proxmox-debian#prerequisites)
- [## Build](https://github.com/sujiba/packer-proxmox-debian#build)
- [## Acknowledgement](https://github.com/sujiba/packer-proxmox-debian#acknowledgement)

## Introduction
**Packer**:
- Packer is a tool for building identical machine images for multiple platforms from a single source configuration.

**Proxmox**
- Proxmox VE is a complete open-source platform for enterprise virtualization. With the built-in web interface you can easily manage VMs and containers, software-defined storage and networking, high-availability clustering, and multiple out-of-the-box tools on a single solution.

**Debian**
- Debian is an operating system and a distribution of Free Software. It is maintained and updated through the work of many users who volunteer their time and effort.

## Prerequisites
- Install [packer](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli)
- Install [Proxmox VE](https://www.proxmox.com/en/proxmox-ve/get-started)
- Download the [Debian netinst CD image](https://www.debian.org/releases/bullseye/debian-installer/index)
- Download the repository

## Build
Copy variables.pkrvars.hcl.template to variables.pkrvars.hcl and change the parameters
```
cp variables.pkrvars.hcl.template variables.pkrvars.hcl
vi variables.pkrvars.hcl
```

To start the build process use the following command:
```
packer build -var-file=./variables.pkrvars.hcl debian.pkr.hcl
```
## Acknowledgement
- [Packer](https://github.com/hashicorp/packer)
- [Proxmox](https://www.proxmox.com/en/proxmox-ve)
- [Debian](https://www.debian.org/)