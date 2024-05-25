resource "kubernetes_persistent_volume" "minio_pv" {
  metadata {
    name = "minio-pv"
  }
  spec {
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      local {
        path = var.minio_volume_path
      }
    }
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = [var.minikube_node_hostname]
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "minio_pvc" {
  metadata {
    name      = "minio-pvc"
    namespace = var.argo_namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.minio_pv.metadata[0].name
  }
}

resource "kubernetes_stateful_set" "minio" {
  metadata {
    name      = "minio"
    namespace = var.argo_namespace
  }
  spec {
    service_name = "minio"
    replicas     = 1
    selector {
      match_labels = {
        app = "minio"
      }
    }
    template {
      metadata {
        labels = {
          app = "minio"
        }
      }
      spec {
        container {
          name  = "minio"
          image = "minio/minio"
          args  = ["server", "/data", "--console-address", ":9001"]
          port {
            container_port = 9000
          }
          port {
            container_port = 9001
          }
          env {
            name  = "MINIO_ROOT_USER"
            value = var.minio_root_user
          }
          env {
            name  = "MINIO_ROOT_PASSWORD"
            value = var.minio_root_password
          }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "data"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "10Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "minio" {
  metadata {
    name      = var.minio_service_name
    namespace = var.argo_namespace
  }
  spec {
    selector = {
      app = "minio"
    }
    port {
      port        = var.minio_service_port
      target_port = 9000
    }
    port {
      port        = 9001
      target_port = 9001
    }
  }
}

resource "null_resource" "minio_port_forward" {
  provisioner "local-exec" {
    command = "kubectl port-forward service/${var.minio_service_name} 9000:9000 -n ${var.argo_namespace} &"
    interpreter = ["bash", "-c"]
  }
}
