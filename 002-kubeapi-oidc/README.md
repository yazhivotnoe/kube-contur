### Kube api oidc integrate


### Client scoup setup for REALM in keycloak

groups 
  - default
  - include in token scoup ON
  mappers:
    - groups ( add -> Configure -> Group memberships -> groups ) | Full group path OFF ( so that there is no nesting )
      - name: groups
      - token claim name: groups


### Add oidc setting for kube-api

- auth.yml config example
```yaml
apiVersion: apiserver.config.k8s.io/v1beta1
kind: AuthenticationConfiguration
jwt:
- issuer:
    url: https://<keycloak-url>/realms/<realm>
    audiences:
    - kubernetes # client ids
    audienceMatchPolicy: MatchAny
  claimMappings:
    username:
      expression: 'claims.preferred_username'
    groups:
      expression: 'claims.groups'
```

- on each master node
```bash
sudo -i
cd /etc/kubernetes
mkdir configs
cat >> configs/auth.yml << EOF
apiVersion: apiserver.config.k8s.io/v1beta1
kind: AuthenticationConfiguration
jwt:
- issuer:
    url: https://<keycloak-url>/realms/kubernetes
    audiences:
    - kube-api # client ids from realm
    audienceMatchPolicy: MatchAny
  claimMappings:
    username:
      expression: 'claims.preferred_username'
    groups:
      expression: 'claims.groups'
EOF

vim manifests/kube-apiserver.yaml
# add the following line
#   --oidc-issuer-url=https://<keycloak-url>/realms/<realm>
#   --oidc-client-id=<client-id>
#   --oidc-username-claim=preferred_username
#   --oidc-groups-claim=groups
# # or
#   --authentication-config=/etc/kubernetes/configs/auth.yml


#   volumeMounts:
    # - mountPath: /etc/kubernetes/configs
    #   name: kube-configs
    #   readOnly: true

# volumes:
  # - hostPath: 
  #     path: /etc/kubernetes/configs
  #     type: DirectoryOrCreate
  #   name: kube-configs


touch manifests/kube-apiserver.yaml
```

## Get Access to cluster via OIDC

- [with Light UI](./LIGHT.md)
- [manual](./MANUAL.md)

