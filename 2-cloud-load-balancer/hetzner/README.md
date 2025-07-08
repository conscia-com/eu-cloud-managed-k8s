# Hetzner Cloud

## Prerequisites

- Create `cloud-init` folder in the root of the project
- Create files `cloud-init/controller.yaml` and `cloud-init/worker.yaml` using the templates in the `cloud-init-examples` folder

## .env file

```bash
export HCLOUD_TOKEN=         # Get this from the Hetzner Cloud console
export TF_VAR_hcloud_token=  # same as above
export TF_VAR_my_ip=         # Your public IP address
```

## Hetzner k3s installation

```bash
source .env
terraform init
terraform plan
terraform apply

CONTROLLER="x.x.x.x" # public IP of controller from terraform output
ssh -A root@$CONTROLLER -i ~/.ssh/tcloud
cat /etc/rancher/k3s/k3s.yaml
# copy the content to your local machine: ~/.kube/config
# change IP to controller public IP and name to k3s

kubectl config use-context k3s
kubectl get nodes
```

## Deploy cloud load balancer Helm chart

```bash
helm repo add hcloud https://charts.hetzner.cloud
helm repo update

kubectl create secret generic hcloud \
--from-literal=token=$HCLOUD_TOKEN

helm install hcloud-cloud-controller-manager hcloud/hcloud-cloud-controller-manager \
--set hcloud.token=$HCLOUD_TOKEN \
--set controller.watchTag=k3s  
```

## Hetzner pod deployment

```bash
kubectl apply -f example-service.yaml
kubectl get svc example-service # Get the external IP address
curl http://<external-ip>:8001
```
