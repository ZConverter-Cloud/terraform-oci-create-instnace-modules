resource "oci_core_network_security_group" "create_network_security_group" {
  count          = var.create_security_group_rules != null ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = data.oci_core_subnet.get_subnet_infomation.vcn_id

  display_name = "${var.vm_name}-security-groups"
}

resource "oci_core_network_security_group_security_rule" "ingress" {
  count = length(local.ingress_create_security_group_rules)
  network_security_group_id = oci_core_network_security_group.create_network_security_group[0].id
  direction = upper(local.ingress_create_security_group_rules[count.index].direction)
  protocol = local.protocol[lower(local.ingress_create_security_group_rules[count.index].protocol)]
  source = local.ingress_create_security_group_rules[count.index].remote_ip_prefix
  source_type = "CIDR_BLOCK"

  dynamic "tcp_options" {
    for_each = contains(["tcp", "tcpv6"], lower(local.ingress_create_security_group_rules[count.index].protocol)) ? [1] : []
    content {
      destination_port_range {
        min = local.ingress_create_security_group_rules[count.index].port_range_min == 0 ? 1 : local.ingress_create_security_group_rules[count.index].port_range_min
        max = local.ingress_create_security_group_rules[count.index].port_range_max == 0 ? 65535 : local.ingress_create_security_group_rules[count.index].port_range_max
      }
    }
  }

  dynamic "udp_options" {
    for_each = contains(["udp", "udpv6"], lower(local.ingress_create_security_group_rules[count.index].protocol)) ? [1] : []
    content {
      destination_port_range {
        min = local.ingress_create_security_group_rules[count.index].port_range_min == 0 ? 1 : local.ingress_create_security_group_rules[count.index].port_range_min
        max = local.ingress_create_security_group_rules[count.index].port_range_max == 0 ? 65535 : local.ingress_create_security_group_rules[count.index].port_range_max
      }
    }
  }

  dynamic "icmp_options" {
    for_each = contains(["icmp", "icmpv6"], lower(local.ingress_create_security_group_rules[count.index].protocol)) ? [1] : []
    content {
      type = local.ingress_create_security_group_rules[count.index].type
      code = local.ingress_create_security_group_rules[count.index].code
    }
  }
}

resource "oci_core_network_security_group_security_rule" "egress" {
  count = length(local.egress_create_security_group_rules)
  network_security_group_id = oci_core_network_security_group.create_network_security_group[0].id
  direction = upper(local.egress_create_security_group_rules[count.index].direction)
  protocol = local.protocol[lower(local.egress_create_security_group_rules[count.index].protocol)]
  destination = local.egress_create_security_group_rules[count.index].remote_ip_prefix
  destination_type = "CIDR_BLOCK"

  dynamic "tcp_options" {
    for_each = contains(["tcp", "tcpv6"], lower(local.egress_create_security_group_rules[count.index].protocol)) ? [1] : []
    content {
      destination_port_range {
        min = local.egress_create_security_group_rules[count.index].port_range_min == 0 ? 1 : local.egress_create_security_group_rules[count.index].port_range_min
        max = local.egress_create_security_group_rules[count.index].port_range_max == 0 ? 65535 : local.egress_create_security_group_rules[count.index].port_range_max
      }
    }
  }

  dynamic "udp_options" {
    for_each = contains(["udp", "udpv6"], lower(local.egress_create_security_group_rules[count.index].protocol)) ? [1] : []
    content {
      destination_port_range {
        min = local.egress_create_security_group_rules[count.index].port_range_min == 0 ? 1 : local.egress_create_security_group_rules[count.index].port_range_min
        max = local.egress_create_security_group_rules[count.index].port_range_max == 0 ? 65535 : local.egress_create_security_group_rules[count.index].port_range_max
      }
    }
  }

  dynamic "icmp_options" {
    for_each = contains(["icmp", "icmpv6"], lower(local.egress_create_security_group_rules[count.index].protocol)) ? [1] : []
    content {
      type = local.egress_create_security_group_rules[count.index].type
      code = local.egress_create_security_group_rules[count.index].code
    }
  }
}
