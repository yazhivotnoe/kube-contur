include {
  path = find_in_parent_folders("terragrunt.hcl")
}

dependencies {
  paths = ["../prometheus", "../ingress-nginx"]
}

locals {
  vars = read_terragrunt_config(format("%s/%s", get_parent_terragrunt_dir(), "vars/dev.hcl"))
}

terraform {
  source = "https://github.com/yazhivotnoe/tf-mod-kube-grafana.git?ref=main"
}

generate "values_file" {
    path = "files/values.yaml"
    if_exists = "overwrite"

    contents = <<EOF
service:
  enabled: true
  type: ClusterIP
  ipFamilyPolicy: ""
  ipFamilies: []
  loadBalancerIP: ""
  loadBalancerClass: ""
  loadBalancerSourceRanges: []
  port: 80
  targetPort: 3000
  annotations: {}
  labels: {}
  portName: service
  appProtocol: ""
  sessionAffinity: ""

serviceMonitor:
  enabled: false



ingress:
  enabled: false

persistence:
  enabled: false

adminUser: admin
adminPassword: dontalk2me


datasources: 
 datasources.yaml:
    apiVersion: 1
    datasources:
        - name: "Prometheus"
          type: prometheus
          access: proxy
          url: http://prometheus-server.prometheus.svc.cluster.local
          isDefault: true
          jsonData:
            prometheusType: Prometheus
            prometheusVersion: 2.24.0


dashboardProviders:
   dashboardproviders.yaml:
     apiVersion: 1
     providers:
     - name: kube
       orgId: 1
       folder: ''
       type: file
       disableDeletion: false
       editable: true
       options:
         path: /var/lib/grafana/dashboards/kube

dashboards:
  kube:
    kube_nodes_view:
      url: ${local.vars.locals.grafana_dashboard_kube_node_view_url}
      gitlabToken: ""

    kube_global_view:
      url: ${local.vars.locals.grafana_dashboard_kube_global_view_url}
      gitlabToken: ""

    kube_namespace_view:
      url: ${local.vars.locals.grafana_dashboard_kube_namespace_view_url}
      gitlabToken: ""

    kube_system_api_view:
      url: ${local.vars.locals.grafana_dashboard_kube_system_api_view_url}
      gitlabToken: ""

grafana.ini:
  paths:
    data: /var/lib/grafana/
    logs: /var/log/grafana
    plugins: /var/lib/grafana/plugins
    provisioning: /etc/grafana/provisioning
  analytics:
    check_for_updates: true
  log:
    mode: console
  grafana_net:
    url: https://grafana.net

assertNoLeakedSecrets: false
EOF
}


inputs = {
  config_context  = local.vars.locals.config_context
}

