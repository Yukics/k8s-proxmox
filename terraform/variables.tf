variable "env" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "proxmox_url" {
  description = "URL used for connecting to proxmox"
  default     = "https://jondoe.domain.com:8006/api2/json"
  type        = string

  validation {
    condition     = can(regex("^https://.+?:8006/api2/json$", var.proxmox_url))
    error_message = "URL format is https://jondoe.domain.com:8006/api2/json"
  }
}

variable "proxmox_api_token_id" {
  description = "API id used for connecting to proxmox"
  default     = "super-secret"
  type        = string

  validation {
    condition = can(regex("^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+![a-zA-Z0-9._-]+$", var.proxmox_api_token_id))
    error_message = "API Token id is made of <user>@<realm>!<api token name>"
  }
}

variable "proxmox_api_secret" {
  description = "API token used for connecting to proxmox"
  default     = "super-secret"
  type        = string
  sensitive   = true

  validation {
    condition = can(regex("^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}$" , var.proxmox_api_secret))
    error_message = "API token must match <8 char/num>-<4 char/num>-<4 char/num>-<4 char/num>-<12 char/num>"
  }
}
