# ClusterAPI for Scaleway

## Documentation

The content in this document is based on the official Scaleway Cluster API provider documentation, which can be found at the following link:
- [cluster-api-provider-scaleway/docs/getting-started.md](https://github.com/scaleway/cluster-api-provider-scaleway/blob/main/docs/getting-started.md) ([LICENSE](https://github.com/scaleway/cluster-api-provider-scaleway/blob/main/LICENSE))

## Prerequisites
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) installed
- [Clusterctl](https://cluster-api.sigs.k8s.io/user/quick-start.html#install-clusterctl) installed
- [Kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- [Scaleway CLI](https://github.com/scaleway/scaleway-cli) installed

## .env file

```bash
export SCW_ACCESS_KEY=  # Get this from the Scaleway console
export SCW_SECRET_KEY=  # Get this from the Scaleway console
export SCW_PROJECT_ID=  # Scaleway project id
export SCW_REGION=      # Region where you want to create your clusters (e.g. "fr-par")
export SCW_ZONE=        # Zone where you want to create your cluster LB (e.g. "fr-par-1")
```

## Create management cluster

```bash
# Create a cluster with Kind
kind create cluster --name caps-mgt-cluster

# Transform the cluster into a management cluster by using clusterctl init.
clusterctl init --core cluster-api --bootstrap kubeadm --control-plane kubeadm --infrastructure scaleway
```

## Prepare the OS image
In order to provision a workload cluster, you will need to create an OS image with all the necessary dependencies pre-installed (kubeadm, containerd, etc.).

```bash
# import the image provided by Scaleway
source .env
IMAGE_NAME="cluster-api-ubuntu-2404-v1.32.4"
export SNAPSHOT_ID=$(scw block snapshot import-from-object-storage \
  name=$IMAGE_NAME \
  bucket=scwcaps \
  key=images/${IMAGE_NAME}.qcow2 \
  project-id=${SCW_PROJECT_ID} \
  -o json | jq -r .id)

# Wait for the snapshot to be ready
watch scw block snapshot get ${SNAPSHOT_ID}

# Create the image from the snapshot
scw instance image create \
  name=$IMAGE_NAME \
  arch=x86_64 \
  snapshot-id=${SNAPSHOT_ID} \
  project-id=${SCW_PROJECT_ID}
```

## Create your workload cluster

- Set environment variables for cluster:
```bash
export CLUSTER_NAME="workload-cluster"
export CONTROL_PLANE_MACHINE_COUNT=3
export WORKER_MACHINE_COUNT=3
export KUBERNETES_VERSION=1.32.4
export CONTROL_PLANE_MACHINE_IMAGE=$IMAGE_NAME
export WORKER_MACHINE_IMAGE=$IMAGE_NAME
```

- Create your cluster:
```bash
# Generate the manifests defining a workload cluster, and apply them to the bootstrap cluster
clusterctl generate cluster ${CLUSTER_NAME} > ${CLUSTER_NAME}.yaml
kubectl apply -f ${CLUSTER_NAME}.yaml
```

## Wait for the cluster to be created

- Note: nodes will have the NotReady status until a CNI is installed in the cluster.

```bash
# Wait for the cluster to be created
watch clusterctl describe cluster ${CLUSTER_NAME}
  ...
  └─MachineDeployment/my-cluster-md-0                                         False  Warning   WaitingForAvailableMachines  3m31s  Minimum availability requires 1 replicas, current 0 available
    └─Machine/my-cluster-md-0-bgzv8-5k96v                                     True                                          2m15s
        └─MachineInfrastructure - ScalewayMachine/my-cluster-md-0-bgzv8-5k96v
```

- Access the workload cluster:
```bash
# Get the kubeconfig for this new cluster
clusterctl get kubeconfig ${CLUSTER_NAME} > ${CLUSTER_NAME}-kubeconfig.yaml
export KUBECONFIG="${CLUSTER_NAME}-kubeconfig.yaml"

# Verify the cluster is up and running
kubectl get nodes
```

## Install components in your cluster

Your workload cluster is now ready to have components installed (not included in this guide):

- Install a CNI plugin:
```bash
# Install Flannel CNI - You can use your preferred CNI instead, e.g. Cilium
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
# check that the nodes are in ready state (takes a minute)
watch kubectl get nodes
```
- Install the Scaleway CCM to manage Nodes and LoadBalancers e.g.:
```bash
# Create a secret with your Scaleway credentials
kubectl create secret generic scaleway-secret \
  --namespace kube-system \
  --from-literal=SCW_ACCESS_KEY=$SCW_ACCESS_KEY \
  --from-literal=SCW_SECRET_KEY=$SCW_SECRET_KEY \
  --from-literal=SCW_DEFAULT_PROJECT_ID=$SCW_PROJECT_ID \
  --from-literal=SCW_DEFAULT_REGION=$SCW_REGION \
  --from-literal=SCW_DEFAULT_ZONE=$SCW_ZONE

# Deploy the Scaleway CCM
kubectl apply -f https://raw.githubusercontent.com/scaleway/scaleway-cloud-controller-manager/master/examples/k8s-scaleway-ccm-latest.yml

# Verify the CCM is running
kubectl get pods -n kube-system -l app=scaleway-cloud-controller-manager

# Deploy an example LoadBalancer service and verify it works
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: example-service
spec:
  selector:
    app: example
  ports:
    - port: 8765
      targetPort: 9376
  type: LoadBalancer
EOF

kubectl get svc example-service

# Check the Scaleway console for the created LoadBalancer
```

And that's it! You now have a working Kubernetes cluster in Scaleway.

---

## Optional: Delete the workload cluster

```bash
# Delete the example service (and its LoadBalancer)
kubectl delete svc example-service

# Change back to the management cluster kubeconfig
unset KUBECONFIG
kubectl get clusters

# Delete the workload cluster
kubectl delete cluster ${CLUSTER_NAME}

# Delete image and snapshot
IMAGE_ID=$(scw instance image list --output=json | jq -r '.[].id')
scw instance image delete ${IMAGE_ID}
scw block snapshot delete ${SNAPSHOT_ID}

# Delete the management cluster
kind delete cluster --name caps-mgt-cluster
```
