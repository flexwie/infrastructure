terraform {
  backend "s3" {
    bucket                      = "state"
    key                         = "cluster/terraform.tfstate"
    region                      = "eu-frankfurt-1"
    endpoint                    = "https://frzzbgh6jqrt.compat.objectstorage.eu-frankfurt-1.oraclecloud.com"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
