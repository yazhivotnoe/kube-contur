include {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  vars = read_terragrunt_config(format("%s/%s", get_parent_terragrunt_dir(), "vars/dev.hcl"))
}

terraform {
  source = "https://github.com/yazhivotnoe/tf-mod-kube-ingress-nginx.git?ref=main"
}


inputs = {
  config_context  = local.vars.locals.config_context
  service_type = local.vars.locals.dev_ingress_service_type
}