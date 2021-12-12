data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "template_cloudinit_config" "init" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/data/cloudinit.sh", {})
  }
}
