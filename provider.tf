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

variable "bxapikey" {
  description = "Your IBM Cloud Infrastructure (Bluemix) API key."
}

variable "softlayer_username" {
  description = "Your IBM Cloud Infrastructure (SoftLayer) user name."
}

variable "softlayer_api_key" {
  description = "Your IBM Cloud Infrastructure (SoftLayer) API key."
}

##############################################################################
# Configures the IBM Cloud provider
# https://ibm-bluemix.github.io/tf-ibm-docs/
##############################################################################

provider "ibm" {
  bluemix_api_key = "${var.bxapikey}"
  softlayer_username  = "${var.softlayer_username}"
  softlayer_api_key   = "${var.softlayer_api_key}"
}
