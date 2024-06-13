# Experiment with OCM managed application using RBD storage

After [creating](drenv.md) and [setting up](initial-setup.md) an
environment we can deploy an application and try disaster recovery
flows.

In the example we use the busybox deployment for Kubernetes regional DR
environment using RBD storage:

    subscription/deployment-k8s-regional-rbd

This application is deployed in the `deployment-rbd` namespace on the
hub and managed clusters.

## Deploy the application

To deploy the application on cluster `dr1` deploy the *OCM* subscription
on the hub:

```
kubectl apply -k subscription/deployment-k8s-regional-rbd --context hub
```

To inspect the deployed resources on the hub cluster use:

```
kubectl get subscription,placement,managedclustersetbinding -n deployment-rbd --context hub
```

Example output:

```
XXX
```

## Inspecting the deployed application

To find where the application was placed, check the application
`PlacementDecisions` status on the hub:

```
kubectl get placementdecisions -l app=deployment-rbd -n deployment-rbd --context hub \
    -o jsonpath='{.items[0].status.decisions[0].clusterName}{"\n"}'
```

Example output:

```
XXX
```

To inspect the application on the selected cluster use:

```
kubectl get deploy,pod,pvc -n deployment-rbd --context dr1
```

Example output:

```
XXX
```

## Enable DR for the application

To let *Ramen* control the application placement, we must disable *OCM*
scheduling by annotating the application placement:

```
kubectl annotate placement -l app=deployment-rbd -n deployment-rbd \
    cluster.open-cluster-management.io/experimental-scheduling-disable=true
```

Deploy a `DRPlacementControl` resource for the OCM application on the hub:

```
kubectl apply -k dr/managed/deployment-k8s-regional-rbd --context hub
```

To inspect the application DR status use:

```
kubectl get drpc -n deployment-rbd --context hub -o wide -w
```

Example output:

```
XXX
```

To wait until the application data is replicated to the secondary
cluster, use:

```
kubectl wait drpc -l app=deployment-rbd \
    --for condition=Protected \
    --namespace deployment-rbd \
    --timeout 5m \
    --context hub
```

At this point we are ready to simulate a disaster and fail over the
application to the secondary cluster.

## Failover the application to the secondary cluster

XXX

## Relocate the application to the primary cluster

XXX

## Disable DR for the application

> [!IMPORTANT]
> Before disabling DR, ensure that the application placement is pointing
> to the cluster where the workload is currently placed to avoid data
> loss if OCM moves the application to another cluster.

The sample application placement resource does not require any change so
we are ready for disabling DR.

Delete the drpc resource for the OCM application on the hub:

```
kubectl delete -k dr/managed/deployment-k8s-regional-rbd --context hub
```

This deletes the `DRPlacementControl` resource for the busybox
deployment, disabling replication and removing replicated data.

Change the Placement to be reconciled by OCM:

```
kubectl annotate placement placement -n deployment-rbd --context hub \
   cluster.open-cluster-management.io/experimental-scheduling-disable-
```

At this point the application is managed again by *OCM*.

## Undeploy the application

To undeploy the application delete the subscription overlay used to
deploy the application:

```
kubectl delete -k subscription/deployment-k8s-regional-rbd --context hub
```
