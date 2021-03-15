locals {
  lambda_function_id = length(module.lambda_label.id) > 64 ? module.lambda_label.id_brief : module.lambda_label.id
}
