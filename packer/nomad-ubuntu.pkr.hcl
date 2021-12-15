packer {
  required_plugins {
    oracle = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/oracle"
    }
  }
}

variable "oci_file" {
  type    = string
  default = "/home/felix/.oci/config"
}

variable "availability_domain" {
  type = string
  default = "xDFy:EU-FRANKFURT-1-AD-2"
}

variable "base_image" {
  type = string
  default = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaafjetiyrxkw5363xh7gushiwp4jk4ilo2mkltv24tgtxkyqeyjbcq"
}

variable "compartment" {
  type = string
  default = "ocid1.compartment.oc1..aaaaaaaaytzx7mlgya6bho6l6yjhtzl5q56oi4wk2z7aqa7kg26sxpf5zn2q"
}

source "oracle-oci" "arm" {
  access_cfg_file     = var.oci_file
  availability_domain = var.availability_domain
  base_image_ocid     = var.base_image
  compartment_ocid    = var.compartment
  image_name          = "NomadImageARM"
  shape               = "VM.Standard.A1.Flex"
  ssh_username        = "ubuntu"
  subnet_ocid         = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaasrwv7ohizxeksydnl7ayjzkfdr2hdtgonlachne74mfqf63wiggq"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }
}

build {
  sources = ["source.oracle-oci.arm"]

  provisioner "shell" {
    script = "init.sh"
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
