# variable "source_file"{
#     type = string
#     default = null
# }
variable "share_directories"{
    type = list
    default = null
}
variable "storage_account_name"{
    type = string
    default = null
}
variable "account_tier"{
    type = string
    default = null
}
variable "account_replication_type"{
    type = string
    default = null
}
variable "location"{
    type = string
    default = null
}
variable "resource_group_name_for_internetinbound"{
    type = string
    default = null
}
variable "enable_https_traffic_only"{
    type = bool
    default = false
}

variable "file_share_name"{
    type = string
    default = null
}
variable "quota"{
    type = number
    default = 10
}

variable "source_file"{
    type = list
    default = []
}
variable "destination_file"{
    type = list
    default = []
}
variable "path_file"{
    type = list
    default = []
}
