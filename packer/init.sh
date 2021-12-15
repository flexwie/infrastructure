#!/bin/sh
sudo apt-get -qq update
sudo apt-get -qq install unzip -y

echo "-----------------"
echo "Installing Consul"
echo "-----------------"
echo ""

echo "Getting binaries"
export CONSUL_VERSION="1.10.4"
export CONSUL_URL="https://releases.hashicorp.com/consul"

sudo curl --silent --remote-name ${CONSUL_URL}/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_arm64.zip
sudo unzip consul_${CONSUL_VERSION}_linux_arm64.zip
sudo chown root:root consul
sudo mv consul /usr/local/bin/
sudo rm consul_${CONSUL_VERSION}_linux_arm64.zip

echo "Preparing configuration"
sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo mkdir --parents /opt/consul
sudo chown --recursive consul:consul /opt/consul
sudo mkdir --parents /etc/consul.d
sudo touch /etc/consul.d/consul.hcl
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/consul.hcl

sudo consul tls ca create
sudo consul tls cert create -server -dc dc1

echo "----------------"
echo "Installing Nomad"
echo "----------------"
echo ""

echo "Getting binaries"
export NOMAD_VERSION="1.2.3"
sudo curl --silent --remote-name https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_arm64.zip
sudo unzip nomad_${NOMAD_VERSION}_linux_arm64.zip
sudo chown root:root nomad
sudo mv nomad /usr/local/bin/
sudo rm nomad_${NOMAD_VERSION}_linux_arm64.zip

echo "Preparing configuration"
sudo mkdir --parents /opt/nomad
sudo mkdir --parents /etc/nomad.d
sudo chmod 700 /etc/nomad.d
sudo touch /etc/nomad.d/nomad.hcl

echo "Creating configration"
sudo tee -a /etc/nomad.d/nomad.hcl << END
datacenter = "dc1"
data_dir = "/opt/nomad"

client {
  cpu_total_compute = 11200
}
END

sudo tee -a /etc/consul.d/consul.hcl << END
datacenter = "dc1"
data_dir = "/opt/consul"
client_addr = "0.0.0.0"
END

echo "Creating systemd files"
sudo tee -a /etc/systemd/system/consul.service << END
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
Type=exec
User=consul
Group=consul
ExecStart=/usr/bin/consul agent -dev -config-dir=/etc/consul.d/
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
END

sudo tee -a /etc/systemd/system/nomad.service << END
[Unit]
Description=Nomad
Documentation=https://www.nomadproject.io/docs
Wants=network-online.target
After=network-online.target

[Service]
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/nomad agent -dev -bind=0.0.0.0 -config /etc/nomad.d
KillMode=process
KillSignal=SIGINT
LimitNOFILE=infinity
LimitNPROC=infinity
Restart=on-failure
RestartSec=2
StartLimitBurst=3
StartLimitIntervalSec=10
TasksMax=infinity

[Install]
WantedBy=multi-user.target
END

sudo systemctl enable consul
sudo systemctl enable nomad

echo "-----------------"
echo "Installing Docker"
echo "-----------------"
echo ""
curl -fsSL https://get.docker.com | sh