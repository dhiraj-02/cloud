# resource "helm_release" "argocd" {
#   name       = "argocd"
#   namespace  = var.argocd_namespace
#   chart      = "argo-cd"
#   repository = "https://argoproj.github.io/argo-helm"
# }
