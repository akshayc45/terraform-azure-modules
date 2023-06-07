
variable "managementgroups" {
  type = map(object({
    display_name               = string
    name                       = string
    subscription_ids           = optional(list(string))
    parent_management_group_id = optional(string)
  }))
  description = "To create managment group"
  default     = {}
}
