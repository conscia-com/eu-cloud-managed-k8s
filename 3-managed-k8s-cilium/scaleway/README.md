# Scaleway

## Various documentation

- [Scaleway Terraform Quickstart Guide](http://scaleway.com/en/docs/terraform/quickstart/)
- [Terraform documentation](https://registry.terraform.io/providers/scaleway/scaleway/2.0.0-rc.2/docs/resources/k8s_cluster)

## Prerequisistes

- A Scaleway account logged into the [console](https://console.scaleway.com/)
- The [Scaleway CLI](https://www.scaleway.com/en/docs/scaleway-cli/quickstart/)
- initialized the Scaleway configuration file (e.g. via `scw init`)

## First project

- Sign up for Scaleway
- Create a new project `Kubernetes-sandbox`
- Create API key

## .env file

```bash
export SCW_SECRET_KEY=
export TF_VAR_project=
export TF_VAR_trusted_ip= # e.g. "1.2.3.4/32"
```

## Provision cluster

```bash
source .env
terraform init
terraform plan
terraform apply
```

## Connect to the cluster

```bash
CLUSTER_ID_FULL= ... # Get the cluster ID from the terraform output
CLUSTER_NAME= ...    # Get the cluster name from the terraform output

CLUSTER_ID=$(echo $CLUSTER_ID_FULL | cut -d  "/" -f 2)
CONTEXT_NAME="admin@${CLUSTER_NAME}-${CLUSTER_ID}"

scw k8s kubeconfig install $CLUSTER_ID
kubectl config use-context $CONTEXT_NAME
```
