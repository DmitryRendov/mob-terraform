locals {
  role_name = "global"
  team      = "ops"

  security_hub_enabled = false

  config_enabled                     = true
  config_recorder_enabled            = true
  config_recorder_delivery_frequency = "TwentyFour_Hours"
}
