# OVHcloud

## Various documentation

- [Creating your first OVHcloud Public Cloud project](https://help.ovhcloud.com/csm/en-public-cloud-compute-create-project?id=kb_article_view&sysparm_article=KB0050599)
- [First Steps with the OVHcloud APIs](https://help.ovhcloud.com/csm/en-api-getting-started-ovhcloud-api?id=kb_article_view&sysparm_article=KB0042777)
- [Creating a cluster](https://help.ovhcloud.com/csm/en-public-cloud-kubernetes-create-cluster?id=kb_article_view&sysparm_article=KB0049685)
- [Creating a private registry (Harbor) through Terraform](https://help.ovhcloud.com/csm/en-gb-public-cloud-private-registry-creation-via-terraform?id=kb_article_view&sysparm_article=KB0050341)
- [Expose your app deployed on an OVHcloud Managed Kubernetes Service](https://help.ovhcloud.com/csm/en-ie-public-cloud-kubernetes-using-lb?id=kb_article_view&sysparm_article=KB0050008)

## Prerequisites

- OVHcloud project
- OVHcloud API key
- terraform, kubectl installed

## .env file

```bash
export OVH_ENDPOINT=
export OVH_APPLICATION_NAME=
export OVH_APPLICATION_KEY=
export OVH_APPLICATION_SECRET=
export OVH_CONSUMER_KEY=

export TF_VAR_service_name= # id of the OVH Cloud project
export TF_VAR_registry_email=
export TF_VAR_registry_user=
```

## Provision cluster

```bash
source .env
terraform init
terraform plan
terraform apply
```

## Connect to cluster

- Download kubeconfig.yml from OVH control panel
- Set `KUBECONFIG` environment variable
- Run `kubectl`:
```bash
% kubectl get pod -A
NAMESPACE     NAME                                           READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-7d678d9959-65xm5       1/1     Running   0          16m
kube-system   canal-2qvgx                                    2/2     Running   0          12m
kube-system   coredns-56c4c68db4-2stsx                       1/1     Running   0          16m
kube-system   kube-dns-autoscaler-947c866bb-ctcjv            1/1     Running   0          16m
kube-system   kube-proxy-bkvw7                               1/1     Running   0          12m
kube-system   metrics-server-7c6b489b68-4nqx8                1/1     Running   0          16m
kube-system   ovhcloud-apiserver-proxy-gr456                 1/1     Running   0          12m
kube-system   ovhcloud-konnectivity-agent-5f4cd88d49-2shzb   1/1     Running   0          16m
```

## Connect to registry

```bash
terraform output registry-url
terraform output user
terraform output password
```
