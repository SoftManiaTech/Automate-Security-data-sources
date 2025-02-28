output "fortigate_firewall" {
  value = {
    for idx, instance in aws_instance.Fortigate-Firewall :
    instance.tags["Name"] => {
      "Public IP"   = "https://${try(aws_eip.FortiGate-Firewall_eip[idx].public_ip, instance.public_ip)}/login"
      "Private IP"  = instance.private_ip
      "Instance ID" = instance.id
      "SSH client"  = "ssh -i ${var.key_name}.pem admin@${try(aws_eip.FortiGate-Firewall_eip[idx].public_ip, instance.public_ip)}"
    }
  }
}

output "f5_bigip" {
  value = {
    for idx, instance in aws_instance.f5_bigip :
    instance.tags["Name"] => {
      "Public IP"   = "https://${try(aws_eip.f5_bigip_eip[idx].public_ip, instance.public_ip)}:8443"
      "Private IP"  = instance.private_ip
      "Instance ID" = instance.id
      "SSH client"  = "ssh -i ${var.key_name}.pem admin@${try(aws_eip.f5_bigip_eip[idx].public_ip, instance.public_ip)}"
    }
  }
}

output "openvpn" {
  value = {
    for idx, instance in aws_instance.openvpn :
    instance.tags["Name"] => {
      "Public IP"      = try(aws_eip.openvpn_eip[idx].public_ip, instance.public_ip)
      "Private IP"     = instance.private_ip
      "Instance ID"    = instance.id
      "Admin Panel"    = "https://${try(aws_eip.openvpn_eip[idx].public_ip, instance.public_ip)}:943/admin"
      "Client UI"      = "https://${try(aws_eip.openvpn_eip[idx].public_ip, instance.public_ip)}:943/"
      "SSH client"     = "ssh -i ${var.key_name}.pem openvpnas@${try(aws_eip.openvpn_eip[idx].public_ip, instance.public_ip)}"
      "wsl SSH client" = "ssh openvpnas@${try(aws_eip.openvpn_eip[idx].public_ip, instance.public_ip)}"
    }
  }
}

output "ad_dns" {
  value = {
    for idx, instance in aws_instance.ad_dns :
    instance.tags["Name"] => {
      "Public IP"   = try(aws_eip.ad_dns_eip[idx].public_ip, instance.public_ip)
      "Private IP"  = instance.private_ip
      "Instance ID" = instance.id
      "RDP client"  = "mstsc /v:${try(aws_eip.ad_dns_eip[idx].public_ip, instance.public_ip)}"
      "RDP username" = "administrator"
      "RDP password - run this commed to get" = "aws ec2 get-password-data --instance-id ${instance.id} --priv-launch-key ${var.key_name}.pem --region ${var.region}"
    }
  }
}

output "get_password_command" {
  value = "aws ec2 get-password-data --instance-id ${aws_instance.ad_dns[0].id} --priv-launch-key ${var.key_name}.pem --region ${var.region}"
  description = "Run this command to retrieve the Windows administrator password"
}
