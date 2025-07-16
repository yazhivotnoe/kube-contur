include {
  path = find_in_parent_folders("terragrunt.hcl")
}


terraform {
  source = "https://github.com/yazhivotnoe/tf-mod-kube-rbacs.git?ref=main"
}


locals {
  vars = read_terragrunt_config(format("%s/%s", get_parent_terragrunt_dir(), "vars/dev.hcl"))
}



inputs = {
  config_context  = local.vars.locals.config_context
}