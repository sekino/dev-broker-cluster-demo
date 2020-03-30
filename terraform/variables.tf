variable "app_name" {
  default = "broker"
}

variable "env" {
  default = "dev"
}

variable "k8s_version" {
  default = 1.15
}

variable "vpc_id" {
  default = "vpc-08ada0839428874c6"
}

variable "subnet_ids" {
  type = list(string)
  default = ["subnet-051c077c3e19e988d", "subnet-0094ed03af93066e7", "subnet-05a560db8e76aff09"]
}

variable "desired_size" {
  default = 1
}

variable "max_size" {
  default = 10
}

variable "min_size" {
  default = 1
}