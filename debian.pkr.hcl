variable "proxmox_url" {
  type    = string
  default = ""
}

variable "proxmox_node" {
  type    = string
  default = ""
}

variable "proxmox_username" {
  type      = string
  default   = ""
  sensitive = true
}

variable "proxmox_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "iso_file" {
  type    = string
  default = ""
}

variable "ssh_username" {
  type      = string
  default   = ""
  sensitive = true
}

variable "ssh_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "template_name" {
  type    = string
  default = ""
}

variable "vm_name" {
  type    = string
  default = ""
}

variable "vm_id" {
  type = number
}

variable "memory" {
  type = number
}

variable "cores" {
  type = number
}

variable "shell_scripts" {
  description = "A list of scripts."
  type        = list(string)
  default     = []
}

##################################################################################
# SOURCE
##################################################################################
source "proxmox-iso" "debian" {
  proxmox_url              = "${var.proxmox_url}"
  insecure_skip_tls_verify = true
  node                     = "${var.proxmox_node}"
  username                 = "${var.proxmox_username}"
  password                 = "${var.proxmox_password}"
  iso_file                 = "local:iso/${var.iso_file}"

  template_name = "${var.template_name}"
  vm_name       = "${var.vm_name}"
  vm_id         = var.vm_id

  memory  = var.memory
  cores   = var.cores
  sockets = 1
  os      = "l26"

  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  disks {
    type              = "scsi"
    disk_size         = "20G"
    storage_pool      = "local-lvm"
    storage_pool_type = "lvm"
    format            = "raw"
  }

  unmount_iso             = true
  onboot                  = true
  qemu_agent              = true
  scsi_controller         = "virtio-scsi-pci"
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  ssh_username = "${var.ssh_username}"
  ssh_password = "${var.ssh_password}"
  ssh_timeout  = "10m"

  boot_wait      = "6s"
  http_directory = "http"
  boot_command = [
    "<esc><wait>",
    "auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
    "<enter>"
  ]
}

##################################################################################
# BUILD
##################################################################################
build {
  sources = ["source.proxmox-iso.debian"]

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    environment_vars = [
      "BUILD_USERNAME=${var.ssh_username}",
    ]
    inline = [
      "apt -y update && apt -y upgrade",
      "apt -y install python3-pip",
      "pip3 --no-cache-dir install ansible"
    ]
  }

  provisioner "ansible-local" {
    playbook_file = "scripts/install.yml"
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    environment_vars = [
      "BUILD_USERNAME=${var.ssh_username}",
    ]
    scripts           = var.shell_scripts
    expect_disconnect = true
  }
}
