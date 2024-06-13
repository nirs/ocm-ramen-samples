# Experiment with discovered application using CephFS storage

### Enabling CephFS support for base discovered applications

Support for CephFS based application is not complete yet. To test this
feature so you need to enable it in ramen config. Edit
ramen-hub-operator-config in the hub cluster:

```
kubectl edit cm ramen-hub-operator-config -n ramen-system --context hub
```

And enable the `multiNamespaces.volsyncSupported` option:

```
multiNamespace:
  FeatureEnabled: true
  volsyncSupported: true
```

### Deploy the sample application

XXX

### Enable DR for the sample application

To make it possible to fail over or relocate to cluster `dr2` we need to
create the namespace on cluster `dr2`:

```
kubectl create ns deployment-cephfs --context dr2
```

When using Kubernetes clusters we need to annotate the application namespace to
allow volsync to replicate the PVCs:

```
kubectl annotate ns/deployment-cephfs volsync.backube/privileged-movers=true --context dr1
kubectl annotate ns/deployment-cephfs volsync.backube/privileged-movers=true --context dr2
```

> [!NOTE]
> When running on OpenShfit there is no need to annotate the namespace.

To enable DR for the application, apply the DR resources to the hub
cluster:

```
kubectl apply -k dr/discovered/deployment-cephfs --context hub
```

To watch the application DR status run:

```
kubectl get drpc -l app=deployment-cephfs -n ramen-ops --context hub -o wide
```

Example output:

```
XXX
```

### Inspecting the primary cluster

In cluster `dr1`, *Ramen* creates a primary `VolumeReplicationGroup` resource
in the `ramen-ops` namespace, and a `ReplicationSource` resource for every
protected PVC in the application namespace.

To inspect the primary `VolumeReplicationGroup` resource run:

```
kubectl get vrg deployment-cephfs-drpc -n ramen-ops --context dr1
```

Example output:

```
NAME                    DESIREDSTATE   CURRENTSTATE
deployment-cephfs-drpc  primary        Primary
```

To inspect the `ReplicationSource` resources run:

```
kubectl get replicationsource -n deployment-cephfs --context dr1
```

Example output:

```
NAME          SOURCE        LAST SYNC              DURATION        NEXT SYNC
busybox-pvc   busybox-pvc   2024-06-06T23:39:21Z   21.568146815s   2024-06-06T23:40:00Z
```

### Inspecting the secondary cluster

In cluster `dr2`, *Ramen* creates a secondary`VolumeReplicationGroup` resource
in the `ramen-ops` namespace, and a `ReplicationDestination` resources for
every protected PVC in the application namespace.

To inspect the secondary `VolumeReplicationGroup` resource run:

```
kubectl get vrg deployment-cephfs-drpc -n ramen-ops --context dr2
```

Example output:

```
NAME                     DESIREDSTATE   CURRENTSTATE
deployment-cephfs-drpc   secondary      Secondary
```

To inspect the `ReplicationDestination` resources run:

```
kubectl get replicationdestination -n deployment-cephfs --context dr2
```

Example output:

```
NAME          LAST SYNC              DURATION        NEXT SYNC
busybox-pvc   2024-06-06T22:45:25Z   52.882544492s
```

### Failover the sample application

XXX

### Relocate the sample application

XXX

### Disable DR for the sample application

XXX

### Undeploy the sample application

XXX
