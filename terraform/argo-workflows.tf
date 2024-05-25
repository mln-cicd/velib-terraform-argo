resource "helm_release" "argo_workflows" {
  name             = "argo-workflows"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-workflows"
  namespace        = var.argo_namespace
  create_namespace = true

  values = [
    yamlencode({
      artifacts = {
        s3 = {
          bucket = var.minio_bucket
          endpoint = "${var.minio_service_name}.${var.minio_namespace}.svc.cluster.local:${var.minio_service_port}"
          insecure = true
          accessKeySecret = {
            name = "minio-credentials"
            key = "accesskey"
          }
          secretKeySecret = {
            name = "minio-credentials"
            key = "secretkey"
          }
        }
      }
      server = {
        authMode = ""
        extraArgs = ["--auth-mode=server"]
        ingress = {
          enabled = true
          annotations = {
            "nginx.ingress.kubernetes.io/auth-type" = "none"
            "nginx.ingress.kubernetes.io/auth-url" = ""
            "nginx.ingress.kubernetes.io/auth-signin" = ""
          }
        }
      }
    })
  ]

  depends_on = [null_resource.minikube_start, kubernetes_secret.minio_credentials]

  provisioner "local-exec" {
    command     = "kubectl get pods -n ${var.argo_namespace}"
    interpreter = ["bash", "-c"]
    environment = {
      TF_LOG = "DEBUG"
    }
  }
}

resource "null_resource" "argo_port_forward" {
  depends_on = [helm_release.argo_workflows]

  provisioner "local-exec" {
    command = "kubectl port-forward service/argo-workflows-server 2746:2746 -n ${var.argo_namespace} &"
    interpreter = ["bash", "-c"]
    environment = {
      TF_LOG = "DEBUG"
    }
  }
}

resource "null_resource" "check_argo_pods" {
  depends_on = [helm_release.argo_workflows]

  provisioner "local-exec" {
    command = <<EOT
      echo "Checking Argo Workflows Pods Status..."
      kubectl get pods -n ${var.argo_namespace}
      kubectl describe pods -n ${var.argo_namespace}
      kubectl logs -l app.kubernetes.io/name=argo-workflows-server -n ${var.argo_namespace}
    EOT
    interpreter = ["bash", "-c"]
    environment = {
      TF_LOG = "DEBUG"
    }
  }
}

# Deploy Argo Workflow Controller
resource "helm_release" "argo_workflow_controller" {
  name             = "argo-workflow-controller"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-workflow-controller"
  namespace        = var.argo_namespace
  create_namespace = false  # Namespace is already created by argo_workflows

  depends_on = [helm_release.argo_workflows]

  provisioner "local-exec" {
    command     = "kubectl get pods -n ${var.argo_namespace}"
    interpreter = ["bash", "-c"]
    environment = {
      TF_LOG = "DEBUG"
    }
  }
}


resource "null_resource" "check_argo_logs" {
  depends_on = [helm_release.argo_workflows]

  provisioner "local-exec" {
    command = <<EOT
      echo "Checking Argo Workflows Logs..."
      kubectl logs -l app.kubernetes.io/name=argo-workflows-server -n ${var.argo_namespace}
    EOT
    interpreter = ["bash", "-c"]
    environment = {
      TF_LOG = "DEBUG"
    }
  }
}