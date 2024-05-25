# main.tf
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

data "external" "minikube_context" {
  program = ["minikube", "profile", "list", "-o", "json"]
  depends_on = [null_resource.minikube_config]
}

locals {
  minikube_context = jsondecode(data.external.minikube_context.result.stdout)["terraform-cluster"]
}

resource "local_file" "minio_volume_dir" {
  content  = ""
  filename = "${var.minio_volume_path}/.keep"
}

provider "kubernetes" {
  config_context = "terraform-cluster"
  config_path    = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_context = "terraform-cluster"
    config_path    = "~/.kube/config"
  }
}

