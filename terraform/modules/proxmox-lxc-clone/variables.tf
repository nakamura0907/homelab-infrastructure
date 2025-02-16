variable "target_node" {
  description = "(required) - A string containing the cluster node name."
  type        = string
}

variable "hostname" {
  description = "Specifies the host name of the container."
  type        = string
  default     = null
}

variable "clone" {
  description = "The lxc vmid to clone"
  type        = string
}
