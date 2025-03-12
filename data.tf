data "aws_instances" "existing_instances" {
  filter {
    name   = "tag:Name"
    values = ["FortiGate Firewall", "F5 BIG-IP", "OpenVPN", "AD & DNS"]
  }
}


data "aws_security_groups" "existing_fortigate_firewall_sg" {
  filter {
    name   = "group-name"
    values = ["Terraform-fortigate-firewall-sg"]
  }
}

data "aws_security_groups" "existing_sg_f5" {
  filter {
    name   = "group-name"
    values = ["Terraform-f5-bigip-sg"]
  }
}

data "aws_security_groups" "existing_openvpn_sg" {
  filter {
    name   = "group-name"
    values = ["Terraform-openvpn-sg"]
  }
}

data "aws_security_groups" "existing_ad_dns_sg" {
  filter {
    name   = "group-name"
    values = ["Terraform-ad-dns-sg"]
  }
}

