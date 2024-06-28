
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "aks-resource-group"
}

variable "location" {
  description = "The Azure location where the resources will be created"
  type        = string
  default     = "UK South"
}

variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "aks-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.24.6"
}

variable "node_count" {
  description = "Number of AKS worker nodes"
  type        = number
  default     = 2
}
