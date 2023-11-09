# image
#variable "image_id" {
#  description = "The name of the instance_ami"
#  type        = string
#  default     = ""
#}

# instance
variable "instance_type" {
  description = "The name of the instance_type"
  type        = string
  default     = "t3.micro"
}

# server port
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

# tag
variable "tag" {
  type = string
  default = "recipe"
}

# cluster name
variable "cluster" {
  default = "recipe-cluster"
  type    = string
}


# domain
variable "domain" {
  default   = "recipetips.net"
  type      = string
}