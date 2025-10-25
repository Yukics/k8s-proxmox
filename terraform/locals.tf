locals {
    proxmox = yamldecode(file("${path.module}/../variables/${var.env}/proxmox.yml"))["proxmox"]
    k8s = yamldecode(file("${path.module}/../variables/${var.env}/k8s.yml"))["k8s"]
}