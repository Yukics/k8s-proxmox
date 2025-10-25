# https://devlog.brittg.com/posts/homelab-part-1-proxmox/
# https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox/latest/components/builder/iso#example:-fedora-with-kickstart

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_url" {
  type = string
}
variable "proxmox_api_token_id" {
  type = string
}
variable "proxmox_api_secret" {
  type      = string
  sensitive = true
}
variable "proxmox_node" {
  type = string
}

source "proxmox-iso" "ubuntu24" {
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_secret
  node                     = var.proxmox_node
  insecure_skip_tls_verify = true

  template_name        = "ubuntu-24"
  template_description = "ubuntu-24, generated on ${timestamp()}"
  tags                 = "ubuntu-24;template"
  memory               = "4096"
  cores                = "2"
  os                   = "l26"

  ssh_username         = "ubuntu"
  ssh_private_key_file = "~/.ssh/id_ed25519"
  ssh_timeout          = "25m"

  cloud_init = true
  cloud_init_storage_pool = "local"
  additional_iso_files {
    cd_files         = ["./cidata/meta-data", "./cidata/user-data"]
    cd_label         = "cidata"
    unmount          = true
    iso_storage_pool = "local"
  }

  disks {
    format       = "raw"
    disk_size    = "20G"
    storage_pool = "zfs"
    type         = "scsi"
  }

  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  boot      = "order=scsi0;scsi1;ide1;net0"
  boot_wait = "15s"
  boot_command = [
    "<esc><wait>",
    "<esc><wait>",
    "c<wait>",
    "set gfxpayload=keep",
    "<enter><wait>",
    "linux /casper/vmlinuz quiet<wait>",
    " autoinstall<wait>",
    " ds=nocloud;<wait>",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot<enter><wait>",
  ]

  boot_iso {
    type             = "scsi"
    iso_url          = "https://ftp.rediris.es/sites/releases.ubuntu.com/noble/ubuntu-24.04.3-live-server-amd64.iso"
    unmount          = true
    iso_checksum     = "sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"
    iso_storage_pool = "local"
  }

  efi_config {
    efi_storage_pool  = "zfs"
    efi_type          = "4m"
    pre_enrolled_keys = true
  }
}

build {
  name    = "ubuntu24-x86_64"
  sources = ["source.proxmox-iso.ubuntu24"]

  provisioner "shell" {
    execute_command = "echo 'ubuntu' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt-get -y autoremove --purge",
      "sudo apt-get -y clean",
      "sudo apt-get -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo sync"
    ]
  }
}
