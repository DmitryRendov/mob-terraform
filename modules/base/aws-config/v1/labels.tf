module "label" {
  source      = "../../null-label/v1"
  environment = var.environment
  role_name   = var.role_name
}

module "sns_encrypted_kms_label" {
  source      = "../../null-label/v1"
  environment = var.environment
  role_name   = var.role_name
  attributes  = ["sns", "encrypted", "kms"]
}

module "sqs_encryption_check_label" {
  source      = "../../null-label/v1"
  environment = var.environment
  role_name   = var.role_name
  attributes  = ["sqs", "encryption", "check"]
}
