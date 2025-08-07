# ClusterAPI

## Introduction

ClusterAPI is a Kubernetes project that provides declarative APIs and tooling to manage the lifecycle of Kubernetes clusters. It allows users to create, configure, and manage clusters in a consistent way across different infrastructure providers.

## Documentation

The content in this document is based on the Hetzner Community tutorial for the Cluster API provider, which can be found at the following link:
- [Managing Kubernetes on Hetzner with Cluster API](https://community.hetzner.com/tutorials/kubernetes-on-hetzner-with-cluster-api)

## Prerequisites
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) installed
- [Clusterctl](https://cluster-api.sigs.k8s.io/user/quick-start.html#install-clusterctl) installed
- [Kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- [Hetzner Cloud SSH Key](https://docs.hetzner.cloud/#introduction)

## .env file

```bash
export HCLOUD_TOKEN=    # Get this from the Hetzner Cloud console
export HCLOUD_SSH_KEY=  # Name of the SSH key you created in the Hetzner Cloud console
export HCLOUD_REGION=   # Region where you want to create your clusters (e.g., "fsn1", "nbg1", etc.)
```

## Create management cluster

```bash
# Create a cluster with Kind
kind create cluster --name caph-mgt-cluster
kind export kubeconfig --name caph-mgt-cluster

# Transform the cluster into a management cluster by using clusterctl init.
clusterctl init --core cluster-api --bootstrap kubeadm --control-plane kubeadm --infrastructure hetzner

# Replace <YOUR_HCLOUD_TOKEN> with the API token you generated in the previous step
source .env
kubectl create secret generic hetzner --from-literal=hcloud=$HCLOUD_TOKEN
```

## Create your workload cluster

- Set environment variables for cluster:
```bash
export CONTROL_PLANE_MACHINE_COUNT=3 \
export WORKER_MACHINE_COUNT=3 \
export KUBERNETES_VERSION=1.29.4 \
export HCLOUD_CONTROL_PLANE_MACHINE_TYPE=cpx31 \
export HCLOUD_WORKER_MACHINE_TYPE=cpx31
```

- Create your cluster:
```bash
# Source the variables
source cluster_variables.sh

# Generate the manifests defining a workload cluster, and apply them to the bootstrap cluster
clusterctl generate cluster --infrastructure hetzner:v1.0.0-beta.35 hetzner-cluster > workload_cluster.yaml
kubectl apply -f workload_cluster.yaml

# Wait for the cluster to be created
kubectl get clusters -w
```

- Access the workload cluster:
```bash
# Get the kubeconfig for this new cluster
clusterctl get kubeconfig hetzner-cluster > hetzner-cluster-kubeconfig.yaml
export KUBECONFIG=hetzner-cluster-kubeconfig.yaml

# Verify the cluster is up and running
kubectl get nodes
```

## Install components in your cluster

- Install components
```bash
# Install Hetzner CCM
kubectl apply -f https://github.com/hetznercloud/hcloud-cloud-controller-manager/releases/latest/download/ccm.yaml

# Install Flannel CNI - You can use your preferred CNI instead, e.g. Cilium
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

- Configure the Hetzner Cloud Controller Manager
```bash
# Edit the deployment to set the environment variables
kubectl edit deployment hcloud-cloud-controller-manager -n kube-system

        - name: HCLOUD_TOKEN
          valueFrom:
            secretKeyRef:
              key: hcloud
              name: hetzner
```

And that's it! You now have a working Kubernetes cluster in Hetzner Cloud.

---

## Optional: Delete the workload cluster

```bash
# Change back to the management cluster kubeconfig
unset KUBECONFIG
kubectl get clusters

# Delete the workload cluster
kubectl delete cluster hetzner-cluster

# Delete the management cluster
kind delete cluster --name caps-mgt-cluster
```
