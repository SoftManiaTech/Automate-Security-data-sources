output "Fortigate-Firewall_public_ip" {
  value = aws_instance.Fortigate-Firewall.*.public_ip
}

output "f5_bigip_public_ip" {
  value = aws_instance.f5_bigip.*.public_ip
}

output "openvpn_public_ip" {
  value = aws_instance.openvpn.*.public_ip
}

output "ad_dns_public_ip" {
  value = aws_instance.ad_dns.*.public_ip
}
