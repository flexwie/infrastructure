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

  depends_on = [
    local_file.kubeconfig
  ]
}

resource "kubectl_manifest" "argocd" {
  count              = length(data.kubectl_file_documents.argocd.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd.documents, count.index)
  override_namespace = "argo"

  depends_on = [
    kubectl_manifest.namespace
  ]
}

resource "time_sleep" "wait_for_argo" {
  depends_on = [
    kubectl_manifest.argocd
  ]

  create_duration = "10s"

  provisioner "local-exec" {
    command = "./k8s/argo/patch_argocd.sh"
    environment = {
      client_id = azuread_application.argo_auth.application_id,
      tenant_id = data.azuread_client_config.current.tenant_id,
      group_id  = azuread_group.argo_admin.object_id
    }
  }
}

resource "kubectl_manifest" "ingress-nginx" {
  count              = length(data.kubectl_file_documents.apps.documents)
  yaml_body          = element(data.kubectl_file_documents.apps.documents, count.index)
  override_namespace = "argo"

  depends_on = [
    kubectl_manifest.argocd,
  ]
}

