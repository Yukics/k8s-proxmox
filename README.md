# CKA Preparation

## Terraform

Reference: https://registry.terraform.io/providers/Telmate/proxmox/latest/docs

## Inspo

Reference: https://github.com/christensenjairus/ClusterCreator/blob/main/scripts/k8s_vm_template/create_template_helper.sh

## Load env variables

set -a && source .env && set +a

## Packer to Proxmox

```
set -a && source .env && set +a # Load env vars
cd packer/ubuntu-24.04
packer init
packer build ubuntu-24.04.pkr.hcl
```

# Technical debt

1. Boot disk size must be the same on packer and terraform resource (by now 20G).
2. All nodes must have exact same number of disks (/, /var, /tmp)