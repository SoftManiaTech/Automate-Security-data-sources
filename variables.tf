variable "region" {
    description = "The AWS region to deploy resources"
    type        = string
}

variable "key_name" {
  description = "The key name for the EC2 instances"
  type        = string
}

variable "FORTIGATE_FIREWALL" { default = true }
variable "F5_BIG_IP" { default = true }
variable "OPEN_VPN" { default = true }
variable "AD_DNS" { default = true }

variable "ssh_public_key" {
  description = "SSH public key for authentication"
  type        = string
}

variable "ami_map" {
  type = map(object({
    fortigate = string
    f5_bigip  = string
    openvpn   = string
    ad_dns    = string
  }))
  default = {
    "us-east-1" = {
      fortigate = "ami-0c1f6d3eef78627e9"
      f5_bigip  = "ami-02dc10201f9f8a214"
      openvpn   = "ami-06e5a963b2dadea6f"
      ad_dns    = "ami-032ec7a32b7fb247c"
    }
    "us-east-2" = {
      fortigate = "ami-06fc0a905e0ff630d"
      f5_bigip  = "ami-026e01b4dc367c8aa"
      openvpn   = "ami-0a36d74f29e8a3ee9"
      ad_dns    = "ami-034492fa151bbd598"
    }
    "us-west-1" = {
      fortigate = "ami-042ccb57becd96967"
      f5_bigip  = "ami-03aab69ba3aaf69c0"
      openvpn   = "ami-0b95856a935e703f2"
      ad_dns    = "ami-02e77d98d01fe65cd"
    }
    "us-west-2" = {
      fortigate = "ami-0a803e53f18aeb0a6"
      f5_bigip  = "ami-0d7c78bc93733cb96"
      openvpn   = "ami-08e3ff0dfac458a93"
      ad_dns    = "ami-0dbedda2d0007250e"
    }
    "ap-south-1" = {
      fortigate = "ami-005cd41964b26a9f2"
      f5_bigip  = "ami-0ed6e3548a58f6be0"
      openvpn   = "ami-01614d815cf856337"
      ad_dns    = "ami-0e048e14bf321c9be"
    }
    "ca-central-1" = {
      fortigate = "ami-0ce5921eb8fd2ae58"
      f5_bigip  = "ami-019417ce186f48be2"
      openvpn   = "ami-0a14a0a5716389b2d"
      ad_dns    = "ami-05dbaa789b4659a9b"
    }
    "eu-central-1" = {
      fortigate = "ami-01c40219b2f64b301"
      f5_bigip  = "ami-07cbe0b442c41c2be"
      openvpn   = "ami-039470c0765f439c4"
      ad_dns    = "ami-0ca73733a61b323a0"
    }
    "eu-north-1" = {
      fortigate = "ami-019ad0e5e0fc6d1f4"
      f5_bigip  = "ami-06d26933dbf2271a5"
      openvpn   = "ami-0fa20ded58c02ad84"
      ad_dns    = "ami-0c79a29988b3457d4"
    }
    "eu-west-3" = {
      fortigate = "ami-0bb95869b1fd3a9ea"
      f5_bigip  = "ami-0c37aca25bfe54f68"
      openvpn   = "ami-0f0ed9c60250723a7"
      ad_dns    = "ami-09a936c80eb3e8988"
    }
    "eu-west-2" = {
      fortigate = "ami-09acf344cc3d2ff34"
      f5_bigip  = "ami-06bbedc9e578fac06"
      openvpn   = "ami-031c46bb046b90dae"
      ad_dns    = "ami-06ded944ec94dbc92"
    }
    "eu-west-1" = {
      fortigate = "ami-0ed5d8ee00115cf56"
      f5_bigip  = "ami-072b7517c343e2421"
      openvpn   = "ami-0f6f5a74e666160bb"
      ad_dns    = "ami-071ecbc13c113a10e"
    }
    "ap-northeast-3" = {
      fortigate = "ami-0465c7adf0785139a"
      f5_bigip  = "ami-009e3243d4e410a62"
      openvpn   = "ami-0d6eb0b45cbef13b4"
      ad_dns    = "ami-005b5d8b1521b655d"
    }
    "ap-northeast-2" = {
      fortigate = "ami-0122ce57ba92be171"
      f5_bigip  = "ami-04980ca08d6d98abc"
      openvpn   = "ami-09a093fa2e3bfca5a"
      ad_dns    = "ami-0fd5e589cf7513ad6"
    }
    "ap-northeast-1" = {
      fortigate = "ami-05d8726aa3af20849"
      f5_bigip  = "ami-01ccc209db4dc6b32"
      openvpn   = "ami-07ce52c67e2a051d6"
      ad_dns    = "ami-064c02dfbd303620d"
    }
    "ap-southeast-1" = {
      fortigate = "ami-0b284ce7915bde69f"
      f5_bigip  = "ami-08e120779b6545ee9"
      openvpn   = "ami-0c2639422d6fc7d69"
      ad_dns    = "ami-052c7b549329ac235"
    }
    "ap-southeast-2" = {
      fortigate = "ami-01b862243ae2d384f"
      f5_bigip  = "ami-0b98135b8c769397f"
      openvpn   = "ami-056303ef214800fec"
      ad_dns    = "ami-06594fed0e19cf3b9"
    }
  }
}
