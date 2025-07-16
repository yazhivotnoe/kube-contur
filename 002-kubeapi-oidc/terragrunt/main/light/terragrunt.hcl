include {
  path = find_in_parent_folders("terragrunt.hcl")
}


dependencies {
  paths = ["../rbacs"]
}

locals {
  vars = read_terragrunt_config(format("%s/%s", get_parent_terragrunt_dir(), "vars/dev.hcl"))
  env_vars = read_terragrunt_config(format("%s/%s", get_parent_terragrunt_dir(), "env.hcl"))
}

terraform {
  source = "https://github.com/yazhivotnoe/tf-mod-kube-light.git?ref=main"
}


inputs = {
  config_context  = local.vars.locals.config_context
  ingress_enable      = local.vars.locals.light_ingress_enable
  service_enable      = local.vars.locals.light_service_enable
  app_replicas        = local.vars.locals.light_app_replicas
  cluster_name        = local.vars.locals.light_cluster_name
  cluster_api_address = local.vars.locals.light_cluster_api_address
  keycloak_host       = local.vars.locals.light_keycloak_host
  keycloak_realm      = local.vars.locals.light_keycloak_realm
  client_id           = local.vars.locals.light_client_id
  client_secret       = local.env_vars.locals.light_client_secret
}