packer {
  required_plugins {
    oracle = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/oracle"
    }
  }
}

source "oracle-oci" "arm" {
  user_ocid    = "ocid1.user.oc1..aaaaaaaa2nnbpcck3zqybpotnvjuct7he6huyjujdazfeuxvowo2spz6o4fa"
  fingerprint  = "eb:fa:ed:5b:0e:db:64:4c:52:4d:44:a6:16:41:1c:fa"
  tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaag2yyuob7k5chmpigyqno3uvhvts44wvwulfyzlkjsp7mwb3tykzq"
  key_file     = "/home/felix/.oci/oci_api_key.pem"

  availability_domain = "xDFy:EU-FRANKFURT-1-AD-3"
  base_image_ocid     = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaafjetiyrxkw5363xh7gushiwp4jk4ilo2mkltv24tgtxkyqeyjbcq"
  compartment_ocid    = "ocid1.compartment.oc1..aaaaaaaaytzx7mlgya6bho6l6yjhtzl5q56oi4wk2z7aqa7kg26sxpf5zn2q"
  image_name          = "NomadImageARM"
  shape               = "VM.Standard.A1.Flex"
  ssh_username        = "ubuntu"
  subnet_ocid         = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaa67apuacaxjj7gm7lvrjgimler3om4byttzq3fvzs5r4ea3ndzmba"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }
}

build {
  sources = ["source.oracle-oci.arm"]

  provisioner "shell" {
    inline = [
      "echo Adding Repository",
      "curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -",
      "sudo apt-add-repository \"deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main\"",
      "echo Installing Nomad and Consul",
      "sudo apt-get update && sudo apt-get install nomad consul -y"
    ]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
