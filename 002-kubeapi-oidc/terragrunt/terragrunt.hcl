locals {
  env_vars = read_terragrunt_config(format("%s/%s", get_parent_terragrunt_dir(), "env.hcl"))
}


generate "backend" {
    path = "_backend.tf"
    if_exists = "overwrite"

    contents = <<EOF
terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    bucket = "more-tf-backend"
    region = "ru-central1"
    key    = "${trimprefix(format("%s/terraform.tfstate", trimprefix(get_terragrunt_dir(), get_repo_root())), "/")}"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true

    access_key = "${local.env_vars.locals.yandex_access_key}"
    secret_key = "${local.env_vars.locals.yandex_secret_key}"
  }
}
EOF
}