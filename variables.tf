variable "name" {
  default = "ecs"
}
variable "cidr" {
  description = "vpc cidr"
  default     = "11.0.0.0/16"
}

variable "public-subnets" {
  default = ["11.0.0.0/24", "11.0.1.0/24"]
}

variable "container_port" {
  default = "80"
}

variable "container_memory" {
  default = "512"
}

variable "container_cpu" {
  default = "256"
}

variable "container_image" {
  default = "httpd"
}

variable "service_desired_count" {
  default = "1"
}
