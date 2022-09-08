variable "compartment_id" {
  description = "OCID from your tenancy page"
  type        = string
}
variable "region" {
  description = "region where you have OCI tenancy"
  type        = string
  default     = "sa-saopaulo-1"
}

# oci iam availability-domain list
variable "availability_domain" {
  description = "availability domain OCID"
  type        = string
  default = ""
}

# https://docs.oracle.com/en-us/iaas/images/image/1eabae6e-af35-4986-aaf7-820459113753/
variable "image_id" {
  description = "imageId"
  type        = string
}