resource "oci_core_volume" "block_volume" {
  count               = var.additional_volumes != null ? length(var.additional_volumes) : 0
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "${var.vm_name}-${count.index}"
  size_in_gbs         = var.additional_volumes[count.index]
}

resource "oci_core_volume_attachment" "block_attach" {
  count           = var.additional_volumes != null ? length(var.additional_volumes) : 0
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.create_instance.id
  volume_id       = oci_core_volume.block_volume[count.index].id
  device          = var.OS == "Windows" ? null : "${local.volume_device[count.index]}"
  use_chap        = true
}
