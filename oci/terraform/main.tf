terraform {
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = "4.56.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "oci" {
  region = "eu-frankfurt-1"
}

provider "cloudflare" {
  retries = 2
}

module "network" {
  source = "./network"

  compartment_id        = oci_identity_compartment.dev.id
  name                  = "devvcn"
  cidr_block            = "10.0.0.0/16"
  allowed_ingress_ports = [22, 80, 443, 16443, 10250, 25000]

  public_subnets = {
    "public-dev" = {
      cidr_block        = "10.0.2.0/24"
      security_list_ids = []
      optionals         = {}
    }
  }
  private_subnets = {}

  default_security_list_rules = {
    public_subnets = {
      enable_icpm_from_all    = true
      enable_icpm_to_all      = true
      tcp_egress_ports_to_all = [1]
      udp_egress_ports_to_all = [1]
    }
    private_subnets = {
      enable_icpm_from_vcn    = false
      enable_icpm_to_all      = false
      tcp_egress_ports_to_all = [1]
      udp_egress_ports_to_all = [1]
    }
  }
}

resource "oci_identity_compartment" "dev" {
  compartment_id = var.tenancy_ocid
  description    = "Developement Setup"
  name           = "dev"
}

resource "cloudflare_record" "dns-rec" {
  zone_id = var.zone_id
  name    = "dev"
  value   = oci_core_instance.node.public_ip
  type    = "A"
  ttl     = 3600
}

resource "oci_core_instance" "node" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
  compartment_id      = oci_identity_compartment.dev.id
  display_name        = "node"

  shape = "VM.Standard.A1.Flex"
  shape_config {
    memory_in_gbs = 12
    ocpus         = 2
  }

  source_details {
    source_id = jsondecode(file(var.manifest)).builds[0].artifact_id
    #source_id   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaln55u5yyl776hpydrry6gxg6hwlagutrbhdaohemlw5sz4sdf4cq"
    source_type = "image"
  }

  create_vnic_details {
    assign_public_ip          = true
    assign_private_dns_record = true
    subnet_id                 = module.network.public_subnets.public-dev.id
  }

  metadata = {
    "ssh_authorized_keys" = file("~/.ssh/id_rsa.pub")
  }
  preserve_boot_volume = false
}
