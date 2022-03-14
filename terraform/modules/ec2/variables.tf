
variable "namespace" {
  type = string
  default = "my"
}

variable "vpc" {
  type = any
}

variable "sg_pub_id" {
  type = any
}

variable key_name {
  type = string
}