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

  dynamic "ingress" {
    for_each = [ 22, 80, 443, 541, 3000, 8080]
    content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

   user_data = <<-EOF
      #!/bin/bash
      # Wait for the system to be ready
      sleep 70

      # Run tmsh command to change the password
      tmsh modify auth user admin password SoftMania123

      # Save the configuration
      tmsh save sys config
      EOF

    depends_on = [aws_security_group.Terraform-f5_bigip-sg]

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
  count = try(length(data.aws_security_groups.existing_sg_f5.ids), 0) > 0 ? 0 : 1


  name        = "Terraform-f5-bigip-sg"
  description = "Security group for F5 BIG-IP"

  dynamic "ingress" {
  for_each = [22, 80, 443, 541, 8443]
  content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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

 provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "openvpnas"
      private_key = file("${var.key_name}.pem")
      host = self.public_ip
    }

    inline = [
       "echo '${var.ssh_public_key}' >> ~/.ssh/authorized_keys"
    ]
  }


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

  dynamic "ingress" {
  for_each = [22, 443, 943, 945]
  content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
  instance_type = "t2.large"
  key_name      = var.key_name
  security_groups = length(aws_security_group.Terraform-ad_dns-sg) > 0 ? [aws_security_group.Terraform-ad_dns-sg[0].name] : []

  tags = { Name = "AD & DNS" }

  root_block_device {
    volume_size = 50
  }

  associate_public_ip_address = true

  # Automatically enable WinRM using PowerShell
  user_data = <<EOF
    <powershell>
    # Enable WinRM
    winrm quickconfig -q
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm set winrm/config/service/auth '@{Basic="true"}'
    winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'
    netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985
    </powershell>
    EOF
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

  # Allow WinRM HTTPS (port 5986) - Recommended for security
  # Allow WinRM HTTP (port 5985) - Not Secure but works for testing
  
  dynamic "ingress" {
  for_each = [80, 5985, 5986, 3389, 53, 636, 389, 88, 464]
  content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "time_sleep" "wait_190_sec" {
  count         = var.AD_DNS ? 1 : 0
  depends_on = [ aws_instance.ad_dns]

  create_duration = "190s"
}

resource "null_resource" "get_windows_password" {
  count = var.AD_DNS ? 1 : 0
  depends_on = [time_sleep.wait_190_sec]

  provisioner "local-exec" {
    command = <<EOT
    aws ec2 get-password-data --instance-id ${aws_instance.ad_dns[0].id} --priv-launch-key ${var.key_name}.pem --region ${var.region} > windows-password.ini
    EOT
  }
}

resource "time_sleep" "wait_10_seconds" {
  depends_on = [aws_instance.openvpn, aws_eip.openvpn_eip]
  create_duration = "10s"
}

resource "local_file" "ovpn_inventory" {
  count = var.OPEN_VPN ? 1 : 0
  depends_on = [time_sleep.wait_10_seconds]
  filename   = "ovpn.ini"

  content = <<EOF
[openvpn_servers]
openvpn_host ansible_host=${aws_eip.openvpn_eip[0].public_ip} ansible_user=openvpnas
EOF
}

resource "local_file" "windows_inventory" {
  count = var.AD_DNS ? 1 : 0
  depends_on = [null_resource.get_windows_password]
  filename   = "inventory.ini"

  content = <<EOF
[windows]
windows_server ansible_host=${aws_eip.ad_dns_eip[0].public_ip} ansible_user=Administrator ansible_password="${jsondecode(file("windows-password.ini"))["PasswordData"]}" ansible_connection=winrm ansible_winrm_transport=basic ansible_port=5985 ansible_winrm_server_cert_validation=ignore
EOF
}
