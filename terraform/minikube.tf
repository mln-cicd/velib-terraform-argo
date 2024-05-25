resource "null_resource" "minikube_start" {
  provisioner "local-exec" {
    command = "minikube start --profile terraform-cluster"
    interpreter = ["bash", "-c"]
    environment = {
      TF_LOG = "DEBUG"
    }
  }

  provisioner "local-exec" {
    command = "minikube status --profile terraform-cluster"
    interpreter = ["bash", "-c"]
    environment = {
      TF_LOG = "DEBUG"
    }
  }
}

resource "null_resource" "minikube_config" {
  provisioner "local-exec" {
    command = "minikube update-context terraform-cluster"
  }

  depends_on = [null_resource.minikube_start]
}

resource "null_resource" "minikube_dashboard" {
  provisioner "local-exec" {
    command = "minikube dashboard --profile terraform-cluster &"
  }

  depends_on = [null_resource.minikube_start]
}