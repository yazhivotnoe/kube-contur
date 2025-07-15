# Contur

## Instruction have many manual steps, i think its better for the first time and all manual action can be automated in the feature

### Install HA cluster via kubespray

- clone and setup test-cluser inventory
```bash
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray/
cp -rfp inventory/sample inventory/test-cluster
```

- crete hosts file
```bash
# need to change ansible_host and ip to exist VMs ip
cat >> inventory/test-cluster/hosts.ini << EOF
[kube_control_plane]
control-plane01 ansible_host=external-ip ip=internal-ip etcd_member_name=etcd1
control-plane02 ansible_host=external-ip ip=internal-ip etcd_member_name=etcd2
control-plane03 ansible_host=external-ip ip=internal-ip etcd_member_name=etcd3

[etcd:children]
kube_control_plane

[kube_node]
worker01 ansible_host=external-ip ip=internal-ip
worker02 ansible_host=external-ip ip=internal-ip
EOF
```

- run playbook
```bash
python3 -m venv venv-ansible
venv-ansible/bin/pip install -r requirements.txt
venv-ansible/bin/ansible-playbook -i inventory/test-cluster/hosts.ini -u user cluster.yml --become --ask-become-pass
```

### Get access to cluster

```bash
ssh user@ANY_MASTER_IP # or ssh alias

# command on master node
sudo -i
mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
```

### Install haproxy and keepalived for HA kube-apiserver
- before need to edit 001-ansible/hosts.ini file for current vms address

```bash
cd 000-ansible

ansible-playbook -u user -i hosts.ini ha-kubeapi.yml --become --ask-become-pass
```

### Regenerate certs on each master node

- on each node run
```bash
sudo -i
mkdir ~/crt-backups
mv /etc/kubernetes/pki/apiserver.{crt,key} ~/crt-backups
vim /etc/kubernetes/kubeadm-config.yaml
# add VIP ip to apiServer.certSANs section, example:
# apiServer:
#   certSANs:
#   - kubernetes
#   - kubernetes.default
#   - kubernetes.default.svc
#   - kubernetes.default.svc.cluster.local
#   - 10.233.0.1
#   - localhost
#   - 127.0.0.1
#   - master-test01
#   - 10.0.11.11
#   - 10.0.11.165 # VIP IP
kubeadm init phase certs apiserver --config /etc/kubernetes/kubeadm-config.yaml
rm -rf ~/crt-backups
```

-  restart kube api after all manupilation on each node
```bash
kubectl delete pod -n kube-system -l component=kube-apiserver
```

### Setup vpn server for access in private network
- setup openVPN, wireguard and other VPN service, prefer with user auth opportunity and important with opportunity routing user from client vpn subnet to private network subnet with VIP ip


### Verify VIP ip works correclty
- change cluster address to https://VIP_IP:7443

```bash
kubectl get pods -A
```


### Edit kubelet config to use VIP ip

- on each node

```bash
sudo -i
vim /etc/kubernetes/kubelet.conf
# change cluster adress to VIP ip
systemctl restart kubelet && sleep 2 && systemctl status kubelet
```


### Setup hard and soft eviction in kubelet

- on each node
```bash
sudo -i
vim /etc/kubernetes/kubelet-config.yaml

# eviction setting
evictionHard:
  nodefs.available: "10%"
  imagefs.available: "15%"
evictionSoft:
  nodefs.available: "20%"
  imagefs.available: "25%"
evictionSoftGracePeriod:
  nodefs.available: "2m"
  imagefs.available: "3m"
imageGCHighThresholdPercent: 90
imageGCLowThresholdPercent: 80
# or
cat >> /etc/kubernetes/kubelet-config.yaml <<EOF
# eviction setting
evictionHard:
  nodefs.available: "10%"
  imagefs.available: "15%"
evictionSoft:
  nodefs.available: "20%"
  imagefs.available: "25%"
evictionSoftGracePeriod:
  nodefs.available: "2m"
  imagefs.available: "3m"
imageGCHighThresholdPercent: 90
imageGCLowThresholdPercent: 80
EOF

cat /etc/kubernetes/kubelet-config.yaml # verify

systemctl restart kubelet && sleep 5 && systemctl status kubelet --no-page
```

### Edit some configmaps 
- kubeadm-config
- kube-proxy
- cluster-info


### Deploy metrics service for correclty HPA works

```bash
terragrunt run --all $(for d in base/*; do echo --queue-include-dir "$d"; done) plan && terragrunt run --all $(for d in base/*; do echo --queue-include-dir "$d"; done) apply
```

### Deploy env

- point env
```bash
terragrunt run --all $(for d in dev/*; do echo --queue-include-dir "$d"; done) plan && terragrunt run --all $(for d in dev/*; do echo --queue-include-dir "$d"; done) apply
```
- all env exclude base component
```bash
terragrunt run --all $(for d in base/*; do echo --queue-exclude-dir "$d"; done) plan && terragrunt run --all $(for d in base/*; do echo --queue-exclude-dir "$d"; done) apply
```

- delete all
```
terragrunt run --all destroy
```


### What next ?
- observability
- can deploy argo if use argo for CD
- setup default storageclass and setup working with persist data
- cluster updating
- cluster autoscaling
- etcd backuping
- can setup oauth integration for kubeapi and keycloak for example
- can deploy service mesh
- can setup rbacs, network policy
- environments setup
- hardeding OS