variable "minio_root_user" {
  description = "MinIO root username"
  type        = string
  default     = "admin"
}

variable "minio_root_password" {
  description = "MinIO root password"
  type        = string
  default     = "password"
}

variable "minio_bucket" {
  description = "MinIO bucket name for Argo Workflows"
  type        = string
  default     = "my-bucket"
}

variable "minikube_node_hostname" {
  description = "Minikube node hostname"
  type        = string
  default     = "minikube"
}

variable "argo_namespace" {
  description = "Namespace for Argo Workflows"
  type        = string
  default     = "argo"
}

variable "minio_namespace" {
  description = "Namespace for MinIO"
  type        = string
  default     = "minio"
}

variable "minio_service_name" {
  description = "Service name for MinIO"
  type        = string
  default     = "minio-service"
}

variable "minio_service_port" {
  description = "Service port for MinIO"
  type        = number
  default     = 9000
}

variable "minio_volume_path" {
  description = "Path to the MinIO volume"
  type        = string
  default     = "/home/mln/GIT/0_EXPLORE/velib_project/velib_sca/terraform/volumes/minio"
}