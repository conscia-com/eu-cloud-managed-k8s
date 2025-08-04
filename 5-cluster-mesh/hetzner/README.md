# Install Cluster Mesh on Hetzner Cloud 


## Documentation

The content in this document is based on the Hetzner documentation, which can be found at the following link:
- [Setup your own scalable Kubernetes cluster with the Terraform provider for Hetzner Cloud](https://community.hetzner.com/tutorials/setup-your-own-scalable-kubernetes-cluster)

## Comments

- My k3 install command is
```bash
  - curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-backend=none --disable-network-policy" sh -
```

## Prerequisistes and .env file

- Similar to the installation in [../../2-cloud-load-balancer/hetzner/](../../2-cloud-load-balancer/hetzner/)


## Install k3s with no CNI

```bash
source .env
cd terraform
terraform init
terraform apply

hcloud server list

CLUSTER1=$(terraform output -raw cluster1_pip )
CLUSTER2=$(terraform output -raw cluster2_pip )

ssh -A root@$CLUSTER1 -i ~/.ssh/tcloud
cat /etc/rancher/k3s/k3s.yaml
# copy the content to your local machine: ~/.kube/config
# change IP to controller public IP and name to cluster1

ssh -A root@$CLUSTER2 -i ~/.ssh/tcloud
cat /etc/rancher/k3s/k3s.yaml
# similar to above, copy the content to your local machine: ~/.kube/config
```

## Install Cilium

```bash
kubectl --context cluster1 get nodes

helm install cilium cilium/cilium \
--kube-context cluster1 \
--version 1.17.4 \
--namespace kube-system \
--set k8sServiceHost=$CLUSTER1 \
--set k8sServicePort=6443 \
--set cluster.name=cluster1 \
--set cluster.id=1 \
--set identityAllocationMode=crd \
--set operator.replicas=1 \
--set clustermesh.useAPIServer=true \
--set global.etcd.enabled=true \
--set clustermesh.apiserver.enabled=true \
--set nodeinit.enabled=true \
--set externalIPs.enabled=true \
--set hostServices.enabled=false \
--set k8s.requireIPv4PodCIDR=true \
--set ipam.mode=kubernetes \
--set encryption.enabled=true \
--set encryption.type=wireguard

cilium --context cluster1 status --wait
# ... wait for cilium to be ready

kubectl --context cluster2 get nodes

helm install cilium cilium/cilium \
--kube-context cluster2 \
--version 1.17.4 \
--namespace kube-system \
--set k8sServiceHost=$CLUSTER2 \
--set k8sServicePort=6443 \
--set cluster.name=cluster2 \
--set cluster.id=2 \
--set identityAllocationMode=crd \
--set operator.replicas=1 \
--set clustermesh.useAPIServer=true \
--set global.etcd.enabled=true \
--set clustermesh.apiserver.enabled=true \
--set nodeinit.enabled=true \
--set externalIPs.enabled=true \
--set hostServices.enabled=false \
--set k8s.requireIPv4PodCIDR=true \
--set ipam.mode=kubernetes \
--set encryption.enabled=true \
--set encryption.type=wireguard

cilium --context cluster2 status --wait
# ... wait for cilium to be ready

# check that things are working
kubectl --context cluster1 apply -f ../app/http-sw-app.yaml
kubectl --context cluster1 get pod,deploy,svc
kubectl --context cluster1 exec tiefighter -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
  # Ship landed (WORKING!)

kubectl --context cluster2 apply -f ../app/http-sw-app.yaml
kubectl --context cluster2 get pod,deploy,svc
kubectl --context cluster2 exec tiefighter -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
  # Ship landed (WORKING!)
```

## Configure cluster mesh

```bash
cilium clustermesh enable --context cluster1 --service-type NodePort
cilium clustermesh enable --context cluster2 --service-type NodePort

cilium clustermesh status --context cluster1 --wait
cilium clustermesh status --context cluster2 --wait

cilium clustermesh connect --context cluster1 --destination-context cluster2
```

# Check encryption is working

```bash
kubectl --context cluster1 -n kube-system get pod | grep cilium
kubectl --context cluster1 -n kube-system exec cilium-n2nwq  -- cilium-dbg status | grep Encryption
kubectl --context cluster1 -n kube-system exec -it cilium-n2nwq -- cilium bpf tunnel list
```

# Check that the global service is working

```bash
kubectl --context cluster2 -n kube-system get pod | grep cilium
kubectl --context cluster2 -n kube-system exec -it cilium-qcrjw -- cilium service list
# note that the service has backend in both clusters (see the IPs)

kubectl --context cluster2 delete deploy deathstar
kubectl --context cluster2 -n kube-system exec -it cilium-qcrjw -- cilium service list
# note that the service has backend only in remote cluster (see the IPs)

kubectl --context cluster2 exec tiefighter -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
  # Ship landed (WORKING!)
```