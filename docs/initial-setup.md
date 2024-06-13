# Initial setup

## Clone this git repository

Cloning this repo makes it easy to deploy resources from this
repository:

```
git clone https://github.com/RamenDR/ocm-ramen-samples.git
cd ocm-ramen-samples
```

> [!NOTE]
> When using *GitOps*, the workloads are deployed from github, not from
> your local clone.

## Create DRClusters and DRPolicy

When using the ramen testing environment this step is not needed, but if
you are using your own Kubernetes clusters you need to create the
resources.

Modify the `DRCluster` and `DRpolicy` resources in the `ramen` directory
to match the actual cluster names in your environment, and apply the
kustomization:

```
kubectl apply -k ramen --context hub
```

This creates `DRPolicy` and `DRCluster` resources in the cluster
namespace that can be viewed using:

```
kubectl get drcluster,drpolicy --context hub
```

Example output:

```
XXX
```

## Create an OCM channel resources on the hub

To experiment with OCM managed applications you need to create a channel
resource pointing to this github repository:

```
kubectl apply -k channel --context hub
```

This creates a Channel resource in the `ramen-samples` namespace and
can be viewed using:

```
kubectl get channel ramen-gitops -n ramen-samples --context hub
```

Example output:

```
XXX
```

## Switch kubeconfig to point to the OCM Hub cluster

Most of the commands run on the hub cluster. You can simplify the
commands by configuring the hub cluster as the default context:

```
kubectl config use-context hub
```
