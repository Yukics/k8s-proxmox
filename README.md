# k8s-proxmox

This repo is made for studying CKA exam

## Inspo

Reference: https://github.com/christensenjairus/ClusterCreator/blob/main/scripts/k8s_vm_template/create_template_helper.sh

## Create proxmox API Token

1. User -> Create user terraform on pve
2. API Tokens -> Create API Token related to the previous user
3. Permissions -> Add / -> terraform@pve!terraform-api-key -> PVEVMAdmmin (even Administrator in some cases)

## Prepare variables

### Dev

```shell
# dev
cp .env.example .env.dev # modify
# edit .env.dev
cp -r variables/example variables/dev
# edit variables/dev/k8s.yml
# edit variables/dev/proxmox.yml
```

### Pro

```shell
cp .env.example .env.pro # modify
# edit .env.pro
cp -r variables/example variables/pro
# edit variables/pro/k8s.yml
# edit vim variables/pro/proxmox.yml
```

## Packer

```shell
set -a && source .env.dev && set +a # Load env vars
cd packer/ubuntu-24.04
packer init
packer build ubuntu-24.04.pkr.hcl
```

## Terraform

Reference: https://registry.terraform.io/providers/Telmate/proxmox/latest/docs

```shell
set -a && source .env.dev && set +a # Load env vars
cd terraform
terraform init -backend-config="env/dev.hcl" # or pro.hcl, whatever
terraform plan
terraform apply
```

## Ansible

WARN! This implementation is heavily opinionated. 

# Technical debt

1. Boot disk size must be the same on packer and terraform resource (by now 20G).
2. All nodes must have exact same number of disks (/, /var, /tmp)