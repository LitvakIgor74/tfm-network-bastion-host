variable "vpc_id" {
  type = string
}

variable "vpc_elevel_name_prefix" {
  type = string
}

variable "vpc_not_public_snet_list" {
  type = list(string)
}

variable "vpc_public_snet_list" {
  type = list(string)
}

variable "bastion_instance_type" {
  type = string
}

variable "bastion_image_id" {
  type = string
}

variable "bastion_public_key_file_path" {
  type = string
}