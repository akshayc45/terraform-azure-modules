###################
###### DDOS #######
###################
variable "ddos_prt" {
  type = map(object({
    name     = string
    location = string
    rgname   = string
    tags     = map(string)
    }
  ))
  default = {}
}