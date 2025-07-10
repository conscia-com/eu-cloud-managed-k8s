# Scaleway - Managed Kubernetes and Hubble Observability

## Deploy the cluster

Use the guide provided in [](../3-managed-k8s-cilium/scaleway/README.md) to deploy a Kubernetes cluster on Scaleway.

## Install Hubble

We're using [Scaleway Helm repository](https://github.com/scaleway/helm-charts) to add kubernetes applications packaged by Scaleway.

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add scaleway https://helm.scw.cloud/
helm repo update
helm -n kube-system upgrade --install scaleway-cilium-hubble scaleway/scaleway-cilium-hubble
kubectl -n kube-system rollout restart daemonset cilium
kubectl -n kube-system rollout status daemonset cilium


curl -L --remote-name https://github.com/cilium/hubble/releases/latest/download/hubble-linux-amd64.tar.gz
tar -xvzf hubble-linux-amd64.tar.gz
sudo install hubble /usr/local/bin/

hubble status
hubble observe
```

## Use Hubble UI

- Once the chart is installed, you can forward Hubble UI to the local machine:
```bash
kubectl -n kube-system port-forward svc/hubble-ui 12000:80 &
```

- Then open Hubble UI in a browser at http://localhost:12000
