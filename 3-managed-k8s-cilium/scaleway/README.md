# Scaleway

## Notes

- [Scaleway Terraform Quickstart Guide](http://scaleway.com/en/docs/terraform/quickstart/)

```text
Before you start you must have:
- A Scaleway account logged into the [console](https://console.scaleway.com/)
- The [Scaleway CLI](https://www.scaleway.com/en/docs/scaleway-cli/quickstart/)
- initialized the Scaleway configuration file (e.g. via `scw init`)
```

- See additional info in the [Terraform documentation](https://registry.terraform.io/providers/scaleway/scaleway/2.0.0-rc.2/docs/resources/k8s_cluster)

## First project

- Sign up for Scaleway
- Create a new project `Kubernetes-sandbox`
- Create API key
- Download the Scaleway CLI
```bash
brew install scw
scw init
```

## .env file

```bash
export SCW_SECRET_KEY=
export TF_VAR_project=
export TF_VAR_trusted_ip= # e.g. "1.2.3.4/32"
```

## Provision resources using Terraform
```bash
source .env
terraform init
terraform plan
terraform apply
```
- Connect to the cluster
```bash
# Get the cluster ID from the terraform output
CLUSTER_ID=...
scw k8s kubeconfig install $CLUSTER_ID
```

- Connect to the registry
```bash
# Get the registry ID from the terraform output
# Get the secret key via .env file or from the Scaleway console
REGISTRY_ID="rg.fr-par.scw.cloud/sandbox-a9cd9667"
docker login $REGISTRY_ID -u nologin -p $SCW_SECRET_KEY
```
