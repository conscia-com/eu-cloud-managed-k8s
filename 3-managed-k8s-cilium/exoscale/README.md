# Exoscale

## Various documentation

- [Terraform on Exoscale](https://www.exoscale.com/syslog/terraform-with-exoscale/)
- [Easily deploy an SKS cluster on Exoscale with Terraform](https://www.exoscale.com/syslog/easy-terraform-sks/)

## Prerequisites

- Register an account in the [Exoscale portal](https://portal.exoscale.com/)
- Create an API key

## .env file

```bash
export EXOSCALE_API_KEY=...
export EXOSCALE_API_SECRET=...
```

## Provision cluster

```bash
source .env
terraform init
terraform plan
terraform apply
```

## Connect to cluster

- Get `.kubeconfig`
- Run `kubectl`
```bash
% kubectl get pod -A
NAMESPACE     NAME                                  READY   STATUS    RESTARTS   AGE
kube-system   cilium-6csr5                          1/1     Running   0          5m54s
kube-system   cilium-envoy-wlfvs                    1/1     Running   0          5m54s
kube-system   cilium-operator-55978b7b8d-hqv4j      1/1     Running   0          8m42s
kube-system   cilium-operator-55978b7b8d-rjf5n      0/1     Pending   0          25s
kube-system   coredns-b8b95b8f9-bvplp               1/1     Running   0          25s
kube-system   coredns-b8b95b8f9-tsjj4               0/1     Pending   0          25s
kube-system   konnectivity-agent-7d67ff69dc-d8n26   0/1     Pending   0          25s
kube-system   konnectivity-agent-7d67ff69dc-n2srq   1/1     Running   0          8m34s
kube-system   metrics-server-78bf87754c-nsrnb       1/1     Running   0          25s
```
