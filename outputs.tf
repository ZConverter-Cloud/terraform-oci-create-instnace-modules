locals {
  user_name = var.OS == "Windows" ? try(data.oci_core_instance_credentials.instance_credential[0].username, null) : var.OS == "Canonical Ubuntu" ? "ubuntu" : "opc"
  password  = var.OS == "Windows" ? try(data.oci_core_instance_credentials.instance_credential[0].password, null) : "The public_key's private_key that you wrote in terraform.json"
  volume = try([
    for volume_data in oci_core_volume.block_volume :
    {
      "display_name" : volume_data.display_name,
      "size_in_gbs" : volume_data.size_in_gbs,
      "time_created" : volume_data.time_created
      "volume_attach" : [
        for attach_data in oci_core_volume_attachment.block_attach :
        {
          "attachment_type" : attach_data.attachment_type,
          "state" : attach_data.state,
          "time_created" : attach_data.time_created
        }
        if attach_data.volume_id == volume_data.id
      ]
    }
  ], [])
  security_group_rules = try({
    security_group_name = oci_core_network_security_group.create_network_security_group[0].display_name
    ingress = try([
      for sg_ingress_rule in oci_core_network_security_group_security_rule.ingress :
      {
        direction = sg_ingress_rule.direction
        protocol = sg_ingress_rule.protocol
        source = sg_ingress_rule.source
        source_type = sg_ingress_rule.source_type
        tcp_options = length(sg_ingress_rule.tcp_options) != 0 ? sg_ingress_rule.tcp_options : null
        udp_options = length(sg_ingress_rule.udp_options) != 0 ? sg_ingress_rule.udp_options : null
        icmp_options = length(sg_ingress_rule.icmp_options) != 0 ? sg_ingress_rule.icmp_options : null
      }
    ],null)
    egress = try([
      for sg_egress_rule in oci_core_network_security_group_security_rule.egress :
      {
        direction = sg_egress_rule.direction
        protocol = sg_egress_rule.protocol
        source = sg_egress_rule.source
        source_type = sg_egress_rule.source_type
        tcp_options = length(sg_egress_rule.tcp_options) != 0 ? sg_egress_rule.tcp_options : null
        udp_options = length(sg_egress_rule.udp_options) != 0 ? sg_egress_rule.udp_options : null
        icmp_options = length(sg_egress_rule.icmp_options) != 0 ? sg_egress_rule.icmp_options : null
      }
    ],null)
  },null)
  result = tomap({
    "result" : {
      "Instance_information" : {
        "instance_id" : oci_core_instance.create_instance.id,
        "availability_domain" : oci_core_instance.create_instance.availability_domain,
        "display_name" : oci_core_instance.create_instance.display_name,
        "ip" : {
          "hostname" : oci_core_instance.create_instance.create_vnic_details[0].hostname_label,
          "public_ip" : oci_core_instance.create_instance.public_ip,
          "private_ip" : oci_core_instance.create_instance.create_vnic_details[0].private_ip,
        },
        "time_created" : oci_core_instance.create_instance.time_created
      },
      "Connection_information" : {
        "user_name" : local.user_name,
        "user_password" : local.password
      },
      "Volume_Information" : local.volume,
      "Security_Group" : local.security_group_rules
    }
  })
}

# output "result" {
#   value = local.result
# }

# resource "local_file" "output_result" {
#   filename = "${path.cwd}/${var.vm_name}_result.json"

#   content = jsonencode(local.result)
# }

output "result" {
  value = {
    IP = oci_core_instance.create_instance.public_ip,
    OS = "${var.OS}-${var.OS_version}",
    VM_NAME = var.vm_name
  }
}
