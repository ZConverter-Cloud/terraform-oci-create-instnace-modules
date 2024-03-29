terraform {
  required_version = ">= 1.3.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "4.96.0"
    }
  }
}

locals {
  instance_type_split = split(".", "${var.shape_name}")
  ssh_authorized_keys = var.OS != "Windows" ? var.ssh_public_key != null ? var.ssh_public_key : var.ssh_public_key_file_path != null ? base64encode(file(var.ssh_public_key_file_path)) : null : null
  user_data_file_path = var.user_data != null ? base64encode(var.user_data) : var.user_data_file_path != null ? fileexists(var.user_data_file_path) == true ? base64encode(file(var.user_data_file_path)) : null : null
  volume_device = formatlist("/dev/oracleoci/oraclevd%s", [
    "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n",
    "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
    ]
  )
  protocol = {
    "all" : "all",
    "hopopt":"0",
    "icmp":"1",
    "igmp":"2",
    "ggp":"3",
    "ipv4":"4",
    "st":"5",
    "tcp":"6",
    "cbt":"7",
    "egp":"8",
    "igp":"9",
    "bbn-rcc-mon":"10",
    "nvp-ii":"11",
    "pup":"12",
    "argus":"13",
    "emcon":"14",
    "xnet":"15",
    "chaos":"16",
    "udp":"17",
    "mux":"18",
    "dcn-meas":"19",
    "hmp":"20",
    "prm":"21",
    "xns-idp":"22",
    "trunk-1":"23",
    "trunk-2":"24",
    "leaf-1":"25",
    "leaf-2":"26",
    "rdp":"27",
    "irtp":"28",
    "iso-tp4":"29",
    "netblt":"30",
    "mfe-nsp":"31",
    "merit-inp":"32",
    "dccp":"33",
    "3pc":"34",
    "idpr":"35",
    "xtp":"36",
    "ddp":"37",
    "idpr-cmtp":"38",
    "tp++":"39",
    "il":"40",
    "ipv6":"41",
    "sdrp":"42",
    "ipv6-route":"43",
    "ipv6-frag":"44",
    "idrp":"45",
    "rsvp":"46",
    "gre":"47",
    "dsr":"48",
    "bna":"49",
    "esp":"50",
    "ah":"51",
    "i-nlsp":"52",
    "swipe":"53",
    "narp":"54",
    "mobile":"55",
    "tlsp":"56",
    "skip":"57",
    "ipv6-icmp":"58",
    "ipv6-nonxt":"59",
    "ipv6-opts":"60",
    "cftp":"62",
    "sat-expak":"64",
    "kryptolan":"65",
    "rvd":"66",
    "ippc":"67",
    "sat-mon":"69",
    "visa":"70",
    "ipcv":"71",
    "cpnx":"72",
    "cphb":"73",
    "wsn":"74",
    "pvp":"75",
    "br-sat-mon":"76",
    "sun-nd":"77",
    "wb-mon":"78",
    "wb-expak":"79",
    "iso-ip":"80",
    "vmtp":"81",
    "secure-vmtp":"82",
    "vines":"83",
    "ttp":"84",
    "iptm":"84",
    "nsfnet-igp":"85",
    "dgp":"86",
    "tcf":"87",
    "eigrp":"88",
    "ospfigp":"89",
    "sprite-rpc":"90",
    "larp":"91",
    "mtp":"92",
    "ax.25":"93",
    "ipip":"94",
    "micp":"95",
    "scc-sp":"96",
    "etherip":"97",
    "encap":"98",
    "gmtp":"100",
    "ifmp":"101",
    "pnni":"102",
    "pim":"103",
    "aris":"104",
    "scps":"105",
    "qnx":"106",
    "a/n":"107",
    "ipcomp":"108",
    "snp":"109",
    "compaq-peer":"110",
    "ipx-in-ip":"111",
    "vrrp":"112",
    "pgm":"113",
    "l2tp":"115",
    "ddx":"116",
    "iatp":"117",
    "stp":"118",
    "srp":"119",
    "uti":"120",
    "smp":"121",
    "sm":"122",
    "ptp":"123",
    "isis over ipv4":"124",
    "fire":"125",
    "crtp":"126",
    "crudp":"127",
    "sscopmce":"128",
    "iplt":"129",
    "sps":"130",
    "pipe":"131",
    "sctp":"132",
    "fc":"133",
    "rsvp-e2e-ignore":"134",
    "mobility header":"135",
    "udplite":"136",
    "mpls-in-ip":"137",
    "manet":"138",
    "hip":"139",
    "shim6":"140",
    "wesp":"141",
    "rohc":"142",
    "ethernet":"143",
    "aggfrag":"144",
    "reserved":"255"
  }

  ingress_create_security_group_rules = var.create_security_group_rules != null ? [
    for data in var.create_security_group_rules :
    data
    if data.direction == "ingress"
  ] : []

  egress_create_security_group_rules = var.create_security_group_rules != null ? [
    for data in var.create_security_group_rules :
    data
    if data.direction == "egress"
  ] : []
}

variable "region" {
  type    = string
  default = null
}

variable "vm_name" {
  type    = string
  default = ""
}

variable "subnet_ocid" {
  type = string
}

variable "security_group_name" {
  type = string
  default = null
}

variable "create_security_group_rules" {
  type = list(object({
    direction        = optional(string)
    ethertype        = optional(string)
    protocol         = optional(string)
    port_range_min   = optional(string)
    port_range_max   = optional(string)
    remote_ip_prefix = optional(string)
    type             = optional(string)
    code             = optional(string)
  }))
  default = null
}

variable "compartment_ocid" {
  type    = string
  default = null
}

variable "OS" {
  type    = string
  default = null
}

variable "OS_version" {
  type    = string
  default = null
}

variable "custom_image_name" {
  type    = string
  default = null
}

variable "boot_volume_size_in_gbs" {
  type    = number
  default = 50
}

variable "shape_name" {
  type    = string
  default = null
}

variable "shape_cpus" {
  type    = number
  default = 1
}

variable "shape_memory_in_gbs" {
  type    = number
  default = 16
}

variable "ssh_public_key" {
  type    = string
  default = null
}

variable "ssh_public_key_file_path" {
  type    = string
  default = null
}

variable "user_data_file_path" {
  type    = string
  default = null
}

variable "user_data" {
  type = string
  default = null
}

variable "additional_volumes" {
  type    = list(number)
  default = []
}
