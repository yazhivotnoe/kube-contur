### Light

[Light source code](https://github.com/eatmore01/light)

- prepare terragrunt

```bash
cd 001-terragrunt
cat >> env.hcl <<EOF
locals {
  yandex_access_key = "XXXX"
  yandex_secret_key = "XXXX"

  light_client_secret = "XXXXX"
}
EOF


```bash
terragrunt run --all plan
terragrunt run --all apply
```

- port-forwarding svc to localhost -> login in UI -> download full kubeconfig

- or if u install with ingress hostname -> go to hostname -> login in UI -> download full kubeconfig
