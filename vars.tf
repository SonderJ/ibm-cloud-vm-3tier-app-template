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
# Variables
##############################################################################

variable "appname" {
  default = "app"
  description = "Application name for the stack to be deployed."
}
variable "webapp_port" {
  default = "8080"
  description = "Web application port"
}
variable "domain" {
  default = "dbs.com"
  description = "Domain for the computing instance."
}
variable "datacenter" {
  default = "fra02"
  description = "Which data center the VM is to be provisioned in. You can run bluemix cs locations to see a list of all data centers in your region."
}
variable "os_reference_code" {
  default = "CENTOS_7"
  description = "The operating system reference code that is used to provision the computing instance."
}
variable "cores" {
  default = "1"
  description = "The number of CPU cores to allocate."
}
variable "memory" {
  default = "2048"
  description = "The amount of memory to allocate, expressed in MBs."
}
variable "disk_size" {
  default = "25"
  description = "Numeric disk sizes in GBs."
}
variable "private_network_only" {
  default = "false"
  description = "When set to true, a compute instance only has access to the private network."
}
variable "network_speed" {
  default = "100"
  description = "The connection speed (in Mbps) for the instance’s network components."
}
variable "tags" {
  default = "dbsystel"
  description = "Set tags on the VM instance."
}
variable "ssh_user" {
  default = "root"
  description = "The default user for the VM."
}
variable "ssh_label" {
  default = "Admin Key"
  description = "An identifying label to assign to the SSH key."
}
variable "ssh_notes" {
  default = "SSH Key for Administrator"
  description = "Notes to store with the SSH key."
}
variable "ssh_key" {
  default = ""
  description = "The public key material to use in the SSH keypair."
}
