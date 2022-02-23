provider "kubectl" {
  config_path = "~/.kube/config"
}

data "kubectl_file_documents" "namespace" {
  content = file("./k8s/argo/namespace.yml")
}

data "kubectl_file_documents" "argocd" {
  content = file("./k8s/argo/argocd.yml")
}

data "kubectl_file_documents" "apps" {
  content = file("./k8s/argo/apps.yml")
}

resource "kubectl_manifest" "namespace" {
  count              = length(data.kubectl_file_documents.namespace.documents)
  yaml_body          = element(data.kubectl_file_documents.namespace.documents, count.index)
  override_namespace = "argo"
}

resource "kubectl_manifest" "argocd" {
  count              = length(data.kubectl_file_documents.argocd.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd.documents, count.index)
  override_namespace = "argo"

  depends_on = [
    kubectl_manifest.namespace
  ]
}

resource "kubectl_manifest" "ingress-nginx" {
  count              = length(data.kubectl_file_documents.apps.documents)
  yaml_body          = element(data.kubectl_file_documents.apps.documents, count.index)
  override_namespace = "argo"

  depends_on = [
    kubectl_manifest.argocd,
  ]
}
