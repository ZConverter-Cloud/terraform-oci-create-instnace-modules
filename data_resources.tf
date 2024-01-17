data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.compartment_ocid
}

data "oci_core_network_security_groups" "get_network_security_groups_id" {
  count = var.security_group_name != null ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name = var.security_group_name
  vcn_id = data.oci_core_subnet.get_subnet_infomation.vcn_id
}

data "oci_core_images" "InstanceImageOCID" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.OS
  operating_system_version = var.OS != "Windows" ? var.OS_version : var.OS_version == "2012" ? "Server 2012 R2 Standard" : "Server ${var.OS_version} Standard"
  shape                    = var.shape_name

  filter {
    name   = "display_name"
    values = var.custom_image_name == null ? ["^*$"] : [var.custom_image_name]
    regex  = true
  }
}

data "oci_core_subnet" "get_subnet_infomation" {
  subnet_id = var.subnet_ocid
}

data "oci_core_instance_credentials" "instance_credential" {
  count       = var.OS == "Windows" ? 1 : 0
  instance_id = oci_core_instance.create_instance.id
}
