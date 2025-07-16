locals {
  config_context = "kubernetes-admin@cluster.local"

  light_ingress_enable = false
  light_service_enable = true
  light_app_replicas = 1
  light_cluster_name = "test.cluster"
  light_cluster_api_address = "https://10.0.11.222:7443"
  light_keycloak_host = "https://<keycloak.example.url>"
  light_keycloak_realm = "kubernetes"
  light_client_id = "kube-api"
}