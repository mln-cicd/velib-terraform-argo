resource "kubernetes_secret" "minio_credentials" {
  metadata {
    name      = "minio-credentials"
    namespace = var.argo_namespace
  }
  data = {
    accesskey = base64encode(var.minio_root_user)
    secretkey = base64encode(var.minio_root_password)
  }
}
