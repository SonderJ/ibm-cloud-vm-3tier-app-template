################################################################
# Module to deploy an VM with specified applications installed
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# ©Copyright IBM Corp. 2017.
#
################################################################

##############################################################################
# Create security group
##############################################################################

# Create security group for web server instances
resource "ibm_security_group" "dbsystelsg" {
    name = "dbsystel-sg"
    description = "setup security group for dbsystel apps"
}

# Create security group for DB server instance
resource "ibm_security_group" "dbsysteldbsg" {
    name = "dbsystel-db-sg"
    description = "setup security group for dbsystel db"
}

# Security rule for allowing MySQL DB Connections
resource "ibm_security_group_rule" "allow_db_port_3306" {
    direction = "ingress"
    ether_type = "IPv4"
    port_range_min = 3306
    port_range_max = 3306
    protocol = "tcp"
    security_group_id = "${ibm_security_group.dbsysteldbsg.id}"
}

# Security rule for allowing SSH connections to the DB VSI
resource "ibm_security_group_rule" "allow_ssh_access_db" {
    direction = "ingress"
    ether_type = "IPv4"
    port_range_min = 22
    port_range_max = 22
    protocol = "tcp"
    security_group_id = "${ibm_security_group.dbsysteldbsg.id}"
}

# Security rule for allowing outbound connections from the DB VSI
resource "ibm_security_group_rule" "allow_outbound_db" {
    direction = "egress"
    ether_type = "IPv4"
    protocol = "tcp"
    security_group_id = "${ibm_security_group.dbsysteldbsg.id}"
}

# Security rule for allowing access to web application port
resource "ibm_security_group_rule" "allow_app_port_8080" {
    direction = "ingress"
    ether_type = "IPv4"
    port_range_min = 8080
    port_range_max = 8080
    protocol = "tcp"
    security_group_id = "${ibm_security_group.dbsystelsg.id}"
}

# Security rule for allowing SSH connections to the Web VSIs
resource "ibm_security_group_rule" "allow_ssh_access" {
    direction = "ingress"
    ether_type = "IPv4"
    port_range_min = 22
    port_range_max = 22
    protocol = "tcp"
    security_group_id = "${ibm_security_group.dbsystelsg.id}"
}

# Security rule for allowing outbound connections from the Web VSIs
resource "ibm_security_group_rule" "allow_outbound_web" {
    direction = "egress"
    ether_type = "IPv4"
    protocol = "tcp"
    security_group_id = "${ibm_security_group.dbsystelsg.id}"
}

# Security rule for outbound connectivity to all VSIs
# data "ibm_security_group" "allow_outbound" {
#     name = "allow_outbound"
# }

##############################################################################
# Create Resources
##############################################################################

# Create a SSH Key
resource "ibm_compute_ssh_key" "ssh_key" {
    label = "${var.ssh_label}"
    notes = "${var.ssh_notes}"
    public_key = "${var.ssh_key}"
}

# Rendering template for providing MySQL DB IP address to the Web Server instances
data "template_file" "init" {
  template = "${file("install_apache.tpl")}"

  vars {
    TF_MYSQL_PRIVATE_IP = "${ibm_compute_vm_instance.dbs-db.ipv4_address_private}"
  }
}

# Create Web virtual server instances
resource "ibm_compute_vm_instance" "dbs-web" {
  # Variable count determines the number of web server instances to be instantiated
  count                    = "${var.webinstances}"

  hostname                 = "${var.appname}-web-${format("%02d", count.index + 1)}"
  domain                   = "${var.domain}"
  os_reference_code        = "${var.os_reference_code}"
  datacenter               = "${var.datacenter}"
  network_speed            = "${var.network_speed}"
  hourly_billing           = true
  private_network_only     = "${var.private_network_only}"
  cores                    = "${var.cores}"
  memory                   = "${var.memory}"
  disks                    = ["${var.disk_size}"]
  local_disk               = false
  dedicated_acct_host_only = true
  tags                     = ["${var.tags}"]
  user_metadata            = "${data.template_file.init.rendered}"

  # Associate SSH Key for accessing the VSI. Can be associated with multiple SSH Keys.
  ssh_key_ids              = ["${ibm_compute_ssh_key.ssh_key.id}"]

  # Associate security groups
  private_security_group_ids = ["${ibm_security_group.dbsystelsg.id}", "${data.ibm_security_group.allow_outbound.id}"]
  public_security_group_ids = ["${ibm_security_group.dbsystelsg.id}", "${data.ibm_security_group.allow_outbound.id}"]
}

# Create a DB virtual server instance
resource "ibm_compute_vm_instance" "dbs-db" {
  hostname                 = "${var.appname}-db"
  domain                   = "${var.domain}"
  os_reference_code        = "${var.os_reference_code}"
  datacenter               = "${var.datacenter}"
  network_speed            = "${var.network_speed}"
  hourly_billing           = true
  private_network_only     = "${var.private_network_only}"
  cores                    = "${var.cores}"
  memory                   = "${var.memory}"
  disks                    = ["${var.disk_size}"]
  local_disk               = false
  dedicated_acct_host_only = true
  tags                     = ["${var.tags}"]
  user_metadata            = "${file("install_mysql.yml")}"

  # Associate SSH Key for accessing the VSI. Can be associated with multiple SSH Keys.
  ssh_key_ids              = ["${ibm_compute_ssh_key.ssh_key.id}"]

  # Associate security groups
  private_security_group_ids = ["${ibm_security_group.dbsysteldbsg.id}", "${data.ibm_security_group.allow_outbound.id}"]
  public_security_group_ids = ["${ibm_security_group.dbsysteldbsg.id}", "${data.ibm_security_group.allow_outbound.id}"]
}

# Create a Load Balancer routing traffic to the provisioned web server instances
resource "ibm_lbaas" "lbaas" {
  name        = "${var.appname}-lb"
  description = "Load balancer for ${var.appname}"
  # Uses the default (primary) private subnet for provisioning the load balancer
  subnets     = [1610317]

  protocols = [
    {
      frontend_protocol     = "HTTP"
      frontend_port         = 8080
      backend_protocol      = "HTTP"
      backend_port          = 8080
      load_balancing_method = "round_robin"
    }
  ]

  # Associate the web server instances to the load balancer for routing traffic
  server_instances = [
    {
      "private_ip_address" = "${ibm_compute_vm_instance.dbs-web.0.ipv4_address_private}"
    },
    {
      "private_ip_address" = "${ibm_compute_vm_instance.dbs-web.1.ipv4_address_private}"
    }
  ]
}

##############################################################################
# Output
##############################################################################

# Output IP Address of the load balancer for application access
output "lb_id" {
    value = ["http://${ibm_lbaas.lbaas.vip}:8080/DBSystelClusterApp/index.jsp"]
}

# End
