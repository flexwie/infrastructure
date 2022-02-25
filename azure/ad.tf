data "azuread_client_config" "current" {}

resource "azuread_application" "argo_auth" {
  display_name     = "ArgoCD Auth"
  sign_in_audience = "AzureADMultipleOrgs"

  public_client {
    redirect_uris = ["https://argo.haste.cloud/auth/callback"]
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All
      type = "Role"
    }
  }

  group_membership_claims = ["All"]

  provisioner "local-exec" {
    command = "sleep 10 && az ad app permission admin-consent --id ${self.application_id}"
  }
}

resource "azuread_group" "argo_admin" {
  display_name     = "argo-admin-group"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}
