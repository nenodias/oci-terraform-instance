terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
    }
  }
}

data "template_file" "user_data" {
  template = file("cloud-init.yaml")
}

provider "oci" {
  region              = var.region
  auth                = "SecurityToken"
  config_file_profile = "DEFAULT"
}


resource "oci_core_vcn" "milleniun_vcn" {
  dns_label      = "internal"
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_id
  display_name   = "MilleniumVCN"
}

resource "oci_core_subnet" "dev" {
  vcn_id                     = oci_core_vcn.milleniun_vcn.id
  cidr_block                 = "10.0.0.0/24"
  compartment_id             = oci_core_vcn.milleniun_vcn.compartment_id
  display_name               = "Dev subnet"
  prohibit_public_ip_on_vnic = false
  prohibit_internet_ingress  = false
  dns_label                  = "dev"
  dhcp_options_id   = oci_core_vcn.milleniun_vcn.default_dhcp_options_id
  security_list_ids = [
    oci_core_vcn.milleniun_vcn.default_security_list_id
  ]
}


resource "oci_core_default_security_list" "millenium_security_list" {
  compartment_id = var.compartment_id
  manage_default_resource_id = oci_core_vcn.milleniun_vcn.default_security_list_id
  display_name = "MilleniumSecurityList"

  egress_security_rules {
    description = "Internet"
    destination = "0.0.0.0/0"
    protocol = "all"
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    description = "Postgresql"
    protocol = "6" # TCP
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
        min = 5432
        max = 5432
    }

  }
  ingress_security_rules {
    description = "HTTP"
    protocol = "6" # TCP
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
        min = 80
        max = 80
    }

  }

  ingress_security_rules {
    description = "SSH"
    protocol = "6" # TCP
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
        min = 22
        max = 22
    }

  }

  ingress_security_rules {
    description = "ICMP"
    protocol = "1" # ICMP
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    icmp_options {
      type = 3
    }
  }
  ingress_security_rules {
    description = "ICMP"
    protocol = "1" # ICMP
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    icmp_options {
      type = 4
    }
  }

  ingress_security_rules {
    description = "ICMP"
    protocol = "1" # ICMP
    source = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    icmp_options {
      type = 3
    }
  }
}

resource "oci_core_internet_gateway" "millenium_internet_gateway" {
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.milleniun_vcn.id

    display_name = "MilleniumInternetGateway"
    enabled = true
}

resource "oci_core_default_route_table" "millenium_route_table" {
    compartment_id = var.compartment_id
    manage_default_resource_id = oci_core_vcn.milleniun_vcn.default_route_table_id

    display_name = "MilleniumRouteTable"
    route_rules {
        #Required
        network_entity_id = oci_core_internet_gateway.millenium_internet_gateway.id

        description = "Internet Access"
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
    }
}

resource "oci_core_instance" "millenium_server" {
    availability_domain = var.availability_domain
    compartment_id = var.compartment_id
    shape = "VM.Standard.E2.1.Micro"
    shape_config {
      memory_in_gbs = 1
      ocpus         = 1
    }
    display_name = "MilleniumServer"
    source_details {
        source_id = var.image_id
        source_type = "image"
    }
    create_vnic_details {
        assign_public_ip = true
        subnet_id = oci_core_subnet.dev.id
        hostname_label = "postgres"
    }
    metadata = {
        ssh_authorized_keys = file("./ssh.key.pub")
        user_data = base64encode(data.template_file.user_data.rendered)
    } 
    preserve_boot_volume = false
}