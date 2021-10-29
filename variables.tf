variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}


variable "app_image_id" {
  type = string
  default = "ami-0ed34781dc2ec3964"
}
variable "app_instance_type" {
  type = string
  default = "t2.macro"
}
# variable "web_desired_capacity" {
#   type = number
# }
# variable "web_max_size" {
#   type = number
# }
# variable "web_min_size" {
#   type = number
# }
# variable "subnets" {
#   type = list(string)
# }
# variable "security_groups" {
#   type = list(string)
# }
# variable "web_app" {
#   type = string
# }