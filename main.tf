provider "aws" {
  region = var.region
}


resource "aws_instance" "Fortigate-Firewall" {
  count         = var.FORTIGATE_FIREWALL ? 1 : 0
  ami           = lookup(var.ami_map[var.region], "fortigate", "")
  instance_type = "c6i.large"
  key_name      = var.key_name
  security_groups = length(aws_security_group.Terraform-Fortigate-Firewall-sg) > 0 ? [aws_security_group.Terraform-Fortigate-Firewall-sg[0].name] : []

  tags = { Name = "FortiGate Firewall" }

  associate_public_ip_address = true
}

resource "aws_eip" "FortiGate-Firewall_eip" {
  count    = var.FORTIGATE_FIREWALL ? 1 : 0
  instance = aws_instance.Fortigate-Firewall[0].id
}

data "aws_security_groups" "existing_fortigate_firewall_sg" {
  filter {
    name   = "group-name"
    values = ["Terraform-fortigate-firewall-sg"]
  }
}

resource "aws_security_group" "Terraform-Fortigate-Firewall-sg" {
    count = length(data.aws_security_groups.existing_fortigate_firewall_sg.ids) > 0 ? 0 : 1

  name        = "Terraform-fortigate-firewall-sg"
  description = "Security group for FortiGate Firewall"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 541
    to_port     = 541
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "f5_bigip" {
  count         = var.F5_BIG_IP ? 1 : 0
  ami           = lookup(var.ami_map[var.region], "f5_bigip", "")
  instance_type = "t2.medium"
  key_name      = var.key_name
  security_groups = length(aws_security_group.Terraform-f5_bigip-sg) > 0 ? [aws_security_group.Terraform-f5_bigip-sg[0].name] : []

  tags = { Name = "F5 BIG-IP" }

  associate_public_ip_address = true

}

resource "aws_eip" "f5_bigip_eip" {
  count    = var.F5_BIG_IP ? 1 : 0
  instance = aws_instance.f5_bigip[0].id
}

data "aws_security_groups" "existing_sg_f5" {
  filter {
    name   = "group-name"
    values = ["Terraform-f5-bigip-sg"]
  }
}

resource "aws_security_group" "Terraform-f5_bigip-sg" {
    count = length(data.aws_security_groups.existing_sg_f5.ids) > 0 ? 0 : 1

  name        = "Terraform-f5-bigip-sg"
  description = "Security group for F5 BIG-IP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "openvpn" {
  count         = var.OPEN_VPN ? 1 : 0
  ami           = lookup(var.ami_map[var.region], "openvpn", "")
  instance_type = "t2.small"
  key_name      = var.key_name
  security_groups = length(aws_security_group.Terraform-openvpn-sg) > 0 ? [aws_security_group.Terraform-openvpn-sg[0].name] : []

  tags = { Name = "OpenVPN" }

  associate_public_ip_address = true

 user_data = <<-EOF
    #! /bin/bash
    apt-get update -y

    # Download and setup OpenVPN
    curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
    chmod +x openvpn-install.sh

    # Set environment variables for automatic installation
    export APPROVE_INSTALL=y
    export ENDPOINT=$(curl -4 ifconfig.co)
    export APPROVE_IP=y
    export IPV6_SUPPORT=n
    export PORT_CHOICE=1
    export PROTOCOL_CHOICE=1
    export DNS=1
    export COMPRESSION_ENABLED=n
    export CUSTOMIZE_ENC=n
    export CLIENT=david
    export PASS=1   # Enables password protection, but needs a manual password set

    # Run OpenVPN installation
    ./openvpn-install.sh

    # Auto-setup OpenVPN Admin Password (For OpenVPN Access Server)
    if [ -f /usr/local/openvpn_as/scripts/sacli ]; then
      /usr/local/openvpn_as/scripts/sacli --user=admin --new_pass=AdminSecurePass@123 SetLocalPassword
      systemctl restart openvpnas
    fi

    # Auto-setup Client Password (For OpenVPN Client Key)
    CLIENT_NAME="client123@"
    CLIENT_PASSWORD="MySecurePass@1213"
    echo "$$CLIENT_PASSWORD" | openssl rsa -aes256 -in /etc/openvpn/easy-rsa/pki/private/$$CLIENT_NAME.key -out /etc/openvpn/easy-rsa/pki/private/$$CLIENT_NAME-encrypted.key -passout stdin

    # Replace the unencrypted key in the client configuration
    sed -i "s|$$CLIENT_NAME.key|$$CLIENT_NAME-encrypted.key|" /etc/openvpn/client-configs/files/$$CLIENT_NAME.ovpn

    # Ensure OpenVPN is running on boot
    systemctl enable openvpn
    systemctl restart openvpn
EOF


  
  depends_on = [aws_security_group.Terraform-openvpn-sg]

}

resource "aws_eip" "openvpn_eip" {
  count    = var.OPEN_VPN ? 1 : 0
  instance = aws_instance.openvpn[0].id
}

data "aws_security_groups" "existing_openvpn-sg" {
  filter {
    name   = "group-name"
    values = ["Terraform-openvpn-sg"]
  }
}

resource "aws_security_group" "Terraform-openvpn-sg" {
    count = length(data.aws_security_groups.existing_openvpn-sg.ids) > 0 ? 0 : 1

  name        = "Terraform-openvpn-sg"
  description = "Security group for OpenVPN"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 945
    to_port     = 945
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ad_dns" {
  count         = var.AD_DNS ? 1 : 0
  ami           = lookup(var.ami_map[var.region], "ad_dns", "")
  instance_type = "m3.large"
  key_name      = var.key_name
  security_groups = length(aws_security_group.Terraform-ad_dns-sg) > 0 ? [aws_security_group.Terraform-ad_dns-sg[0].name] : []

  tags = { Name = "AD & DNS" }

  associate_public_ip_address = true
}

resource "aws_eip" "ad_dns_eip" {
  count    = var.AD_DNS ? 1 : 0
  instance = aws_instance.ad_dns[0].id
}

data "aws_security_groups" "existing_ad_dns-sg" {
  filter {
    name   = "group-name"
    values = ["Terraform-ad-dns-sg"]
  }
}

resource "aws_security_group" "Terraform-ad_dns-sg" {
    count = length(data.aws_security_groups.existing_ad_dns-sg.ids) > 0 ? 0 : 1

  name        = "Terraform-ad-dns-sg"
  description = "Security group for AD & DNS"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


