resource "random_id" "sa_name_random" {
  byte_length = 8
}

resource "azurerm_storage_account" "storage_account" {
  #count = var.boot_diagnostics && each.value != null ? 1 : 0
  for_each                         = var.storage_account
  account_replication_type         = try(each.value.account_replication_type, "LRS")
  account_tier                     = try(each.value.account_tier, "Standard")
  location                         = each.value.location
  name                             = try(each.value.name, "storage${lower(random_id.sa_name_random.hex)}")
  resource_group_name              = each.value.resource_group_name
  access_tier                      = try(each.value.access_tier, null)
  allow_nested_items_to_be_public  = try(each.value.allow_nested_items_to_be_public, null)
  cross_tenant_replication_enabled = try(each.value.cross_tenant_replication_enabled, null)
  default_to_oauth_authentication  = try(each.value.default_to_oauth_authentication, null)
  enable_https_traffic_only        = try(each.value.enable_https_traffic_only, null)
  min_tls_version                  = try(each.value.min_tls_version, null)
  public_network_access_enabled    = try(each.value.public_network_access_enabled, null)
  shared_access_key_enabled        = try(each.value.shared_access_key_enabled, null)
  tags                             = {}

  dynamic "custom_domain" {
    for_each = lookup(each.value, "custom_domain", [])
    content {
      name          = custom_domain.value.name
      use_subdomain = custom_domain.value.use_subdomain
    }
  }

  dynamic "blob_properties" {
    for_each = lookup(each.value, "blob_properties", [])

    content {
      versioning_enabled            = var.versioning_enabled
      change_feed_enabled           = var.change_feed_enabled
      change_feed_retention_in_days = var.change_feed_retention_in_days
      default_service_version       = var.default_service_version
      last_access_time_enabled      = var.last_access_time_enabled
      dynamic "container_delete_retention_policy" {
        for_each = lookup(each.value.blob_properties, "container_delete_retention_policy", [])

        content {
          days = container_delete_retention_policy.value.days

        }
      }
      dynamic "delete_retention_policy" {
        for_each = lookup(each.value.blob_properties, "delete_retention_policy", [])

        content {
          days = delete_retention_policy.value.days
        }
      }
      dynamic "restore_policy" {
        for_each = lookup(each.value.blob_properties, "restore_policy", [])

        content {
          days = restore_policy.value.restore_policy.days
        }
      }

      dynamic "cors_rule" {
        for_each = lookup(each.value, "cors_rule", [])
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }
    }
  }
  dynamic "customer_managed_key" {
    for_each = lookup(each.value, "customer_managed_key", [])

    content {
      key_vault_key_id          = customer_managed_key.value.key_vault_key_id
      user_assigned_identity_id = customer_managed_key.value.user_assigned_identity_id
    }
  }
  dynamic "identity" {
    for_each = lookup(each.value, "identity", [])

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
}