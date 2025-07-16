### Setup rbacs for groups

- for devops

```bash
cat >> devops-rbacs.yml << EOF
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: devops-role
rules:
- apiGroups: [ "*" ]
  resources: [ "*" ]
  verbs: [ "*" ]
- nonResourceURLs: [ "*" ]
  verbs: [ "*" ]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: devops-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: devops-role
subjects:
- kind: Group
  name: devops
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl apply -f devops-rbacs.yml
```

- for developer
```bash
cat >> devs-rbacs.yml << EOF
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: developer-readonly-access
rules:
- apiGroups: [ "" ]
  resources: [ "*" ]
  verbs: [ "get", "list", "watch" ]
- apiGroups: [ "apps", "extensions", "batch", "networking.k8s.io", "policy", "autoscaling" ]
  resources: [ "*" ]
  verbs: [ "get", "list", "watch" ]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: developer-readonly-access-binding
subjects:
- kind: Group
  name: developers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: developer-readonly-access
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl apply -f devs-rbacs.yml
```


### Get id and refresh token

- with curl
```bash
curl -k -d "grant_type=password" \
  -d "scope=openid" \
  -d "client_id=<client-id>" \
  -d "client_secret=<client=secret>" \
  -d "username=<username>" \
  -d "password=<passowrd>" \
  https://<keycloak-url>/realms/<realm-witj-client>/protocol/openid-connect/token | jq .
```

### add user for kubeconfig

```yml
- name: <username-from-keycloak>
  user:
    auth-provider:
      config:
        client-id: <client-id>
        client-secret: <client-secret>
        id-token: 
        idp-issuer-url: https://<keycloak-url>/realms/<realm-with-client>
        refresh-token: 
      name: oidc
```



