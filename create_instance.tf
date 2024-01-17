resource "oci_core_instance" "create_instance" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = var.vm_name
  shape               = var.shape_name

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = var.subnet_ocid
    nsg_ids = var.create_security_group_rules != null ? [oci_core_network_security_group.create_network_security_group[0].id] : var.security_group_name != null ? [data.oci_core_network_security_groups.get_network_security_groups_id[0].network_security_groups[0].id] : null
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.InstanceImageOCID.images[0].id
    boot_volume_size_in_gbs = "50"
  }

  dynamic "shape_config" {
    for_each = local.instance_type_split[length(local.instance_type_split) - 1] == "Flex" ? [1] : []
    content {
      memory_in_gbs = var.shape_memory_in_gbs
      ocpus         = var.shape_cpus
    }
  }

  metadata = {
    ssh_authorized_keys = local.ssh_authorized_keys
    user_data           = local.user_data_file_path
  }
}
