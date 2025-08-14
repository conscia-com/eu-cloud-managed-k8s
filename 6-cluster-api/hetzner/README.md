# ClusterAPI for Hetzner

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
export HCLOUD_REGION=   # Region where you want to create your clusters (e.g., "fsn1", "nbg1", etc.)
export HCLOUD_SSH_KEY=  # Name of the SSH key you created in the Hetzner Cloud console
export SSH_KEY_NAME=    # Name of the SSH key to use for the cluster nodes
```

## Create management cluster

```bash
# Create a cluster with Kind
kind create cluster --name caph-mgt-cluster

# Transform the cluster into a management cluster by using clusterctl init.
clusterctl init --core cluster-api --bootstrap kubeadm --control-plane kubeadm --infrastructure hetzner

# Add the Hetzner Cloud API token as a secret
source .env
kubectl create secret generic hetzner --from-literal=hcloud=$HCLOUD_TOKEN
```

## Create your workload cluster

- Set environment variables for cluster:
```bash
export CLUSTER_NAME="workload-cluster"
export CONTROL_PLANE_MACHINE_COUNT=1
export WORKER_MACHINE_COUNT=1
export KUBERNETES_VERSION=1.29.4
export HCLOUD_CONTROL_PLANE_MACHINE_TYPE=cpx31
export HCLOUD_WORKER_MACHINE_TYPE=cpx31
```

- Create your cluster:
```bash
# Generate the manifests defining a workload cluster, and apply them to the bootstrap cluster
clusterctl generate cluster --infrastructure hetzner:v1.0.0-beta.43 ${CLUSTER_NAME} > ${CLUSTER_NAME}.yaml
kubectl apply -f ${CLUSTER_NAME}.yaml
```

## Wait for the cluster to be created

- Note: It may take a few minutes for the cluster to be created.  

```bash
# Wait for the cluster to be created
watch clusterctl describe cluster ${CLUSTER_NAME}
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

- Install a CNI plugin:
```bash
# Install Flannel CNI - You can use your preferred CNI instead, e.g. Cilium
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```
- Install the Hetzner CCM to manage Nodes and LoadBalancers e.g.:
```bash
# Install Hetzner CCM
kubectl apply -f https://github.com/hetznercloud/hcloud-cloud-controller-manager/releases/latest/download/ccm.yaml

# Edit the deployment to set the environment variables
kubectl -n kube-system edit deployment hcloud-cloud-controller-manager

        - name: HCLOUD_TOKEN
          valueFrom:
            secretKeyRef:
              key: hcloud
              name: hetzner

# Verify the CCM is running
kubectl -n kube-system get pod  -l app=hcloud-cloud-controller-manager

# Deploy an example LoadBalancer service and verify it works
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: example-service
  annotations:
    load-balancer.hetzner.cloud/location: fsn1
spec:
  selector:
    app: example
  ports:
    - port: 8765
      targetPort: 9376
  type: LoadBalancer
EOF

kubectl get svc example-service

# Check the Hetzner console for the created LoadBalancer
```

And that's it! You now have a working Kubernetes cluster in Hetzner Cloud.

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

# Delete the management cluster
kind delete cluster --name caph-mgt-cluster
```
