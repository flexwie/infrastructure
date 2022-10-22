resource "hcloud_server" "web" {
  name        = "k3s-1"
  image       = "ubuntu-20.04"
  server_type = "cx11"
  datacenter  = "nbg1-dc3"

  ssh_keys = [hcloud_ssh_key.default.id]

  public_net {
    ipv4 = hcloud_primary_ip.main.id

  }
}

resource "hcloud_primary_ip" "main" {
  name          = "entry_point"
  datacenter    = "nbg1-dc3"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = false
}

resource "hcloud_ssh_key" "default" {
  name       = "MacBook"
  public_key = file("~/.ssh/id_rsa.pub")
}
