variable "tenancy_ocid" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "manifest" {
  type        = string
  description = "The Path to Packers output manifest"
  default     = "../packer/manifest.json"
}
