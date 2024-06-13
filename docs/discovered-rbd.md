# Experiment with discovered application using RBD storage

### Deploy the sample application

The sample application is configured to run on cluster `dr1`. To deploy
it on cluster `dr1` we need to create a namespace:

```
kubectl create ns deployment-rbd --context dr1
```

To deploy the application apply the deployment-rbd workload to the
`deployment-rbd` namespace on cluster `dr1`:

```
kubectl apply -k workloads/deployment/k8s-regional-rbd -n deployment-rbd --context dr1
```

To inspect the deployed application use:

```
kubectl get deploy,pod,pvc -n deployment-rbd --context dr1
```

Example output:

```
NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/busybox   1/1     1            1           24s

NAME                           READY   STATUS    RESTARTS   AGE
pod/busybox-6bbf88b9f8-fz2kn   1/1     Running   0          24s

NAME                                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/busybox-pvc   Bound    pvc-c45a3892-167b-4dbc-a250-09c5f288c766   1Gi        RWO            rook-ceph-block   <unset>                 24s
```

### Enable DR for the sample application

To make it possible to fail over or relocate to cluster `dr2` we need to
create the namespace on cluster `dr2`:

```
kubectl create ns deployment-rbd --context dr2
```

To enable DR for the application, apply the DR resources to the hub
cluster:

```
kubectl apply -k dr/discovered/deployment-rbd --context hub
```

To watch the application DR status run:

```
kubectl get drpc -l app=deployment-rbd -n ramen-ops --context hub -o wide
```

Example output:

```
XXX replace with wide output
NAME                  AGE    PREFERREDCLUSTER   FAILOVERCLUSTER   DESIREDSTATE   CURRENTSTATE
deployment-rbd-drpc   103m   dr1                                                 Deployed
```

### Inspecting the primary cluster

In cluster `dr1` *Ramen* creates a primary `VolumeReplicationGroup` resource in
the `ramen-ops` namespace, and a `VolumeReplication` resource for every
protected PVC in the application namespace.

To inspect the primary `VolumeReplicationGroup` run:

```
kubectl get vrg deployment-rbd-drpc -n ramen-ops --context dr1
```

Example output:

```
NAME                  DESIREDSTATE   CURRENTSTATE
deployment-rbd-drpc   primary        Primary
```

To inspect the `VolumeReplication` resources in the application namespace run:

```
kubectl get vr -n deployment-rbd --context dr1
```

Example output:

```
NAME          AGE   VOLUMEREPLICATIONCLASS   PVCNAME       DESIREDSTATE   CURRENTSTATE
busybox-pvc   10m   vrc-sample               busybox-pvc   primary        Primary
```

### Failover the sample application

In case of disaster you can force the application to run on the other
cluster.  The application will start on the other cluster using the data
from the last replication. Data since the last replication is lost.

In the ramen testing environment we can simulate a disaster by pausing
the minikube VM running cluster `dr1`:

```
virsh -c qemu:///system suspend dr1
```

At this point the application is not accessible. To recover from the
disaster, we can fail over the application the secondary cluster.

To start a `Failover` action, patch the application `DRPlacementControl`
resource in the `ramen-ops` namespace on the hub cluster. We need to set
the `action` and `failoverCluster`:

```
kubectl patch drpc deployment-rbd-drpc \
    --patch '{"spec": {"action": "Failover", "failoverCluster": "dr2"}}' \
    --type merge \
    --namespace ramen-ops \
    --context hub
```

The application will start on the failover cluster ("dr2"). Nothing will
change on the primary cluster ("dr1") since it is still paused.

To watch the application status while failing over, run:

```
kubectl get drpc deployment-rbd-drpc -n ramen-ops --context hub -o wide -w
```

Example output:

```
NAME                  AGE   PREFERREDCLUSTER   FAILOVERCLUSTER   DESIREDSTATE   CURRENTSTATE   PROGRESSION        START TIME             DURATION   PEER READY
deployment-rbd-drpc   17m   dr1                dr2               Failover       FailedOver     WaitForReadiness   2024-06-04T18:10:44Z              False
deployment-rbd-drpc   18m   dr1                dr2               Failover       FailedOver     WaitForReadiness   2024-06-04T18:10:44Z              False
deployment-rbd-drpc   18m   dr1                dr2               Failover       FailedOver     Cleaning Up        2024-06-04T18:10:44Z              False
deployment-rbd-drpc   18m   dr1                dr2               Failover       FailedOver     WaitOnUserToCleanUp   2024-06-04T18:10:44Z              False
```

*Ramen* will proceed until the point where the application should be
deleted from the primary cluster ("dr1"). Note the progression
`WaitOnUserToCleanup`.

The application is running now on cluster `dr2`:

```
kubectl get deploy,pod,pvc -n deployment-rbd --context dr2
```

Example output:

```
NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/busybox   1/1     1            1           3m58s

NAME                           READY   STATUS    RESTARTS   AGE
pod/busybox-6bbf88b9f8-fz2kn   1/1     Running   0          3m58s

NAME                                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/busybox-pvc   Bound    pvc-c45a3892-167b-4dbc-a250-09c5f288c766   1Gi        RWO            rook-ceph-block   <unset>                 4m11s
```

To complete the failover, we need to recover the primary cluster, so we
can start replication from the secondary cluster to the primary cluster.

In the ramen testing environment, we can resume the minikube VM running
cluster `dr1`:

```
virsh -c qemu:///system resume dr1
```

When the cluster becomes accessible again, you need to delete the
application from the primary cluster since *Ramen* does not support
deleting applications:

```
kubectl delete -k workloads/deployment/k8s-regional-rbd -n deployment-rbd --context dr1
```

To wait until the application data is replicated again to the other
cluster run:

```
kubectl wait drpc deployment-rbd-drpc \
    --for condition=Protected \
    --namespace ramen-ops \
    --timeout 5m \
    --context hub
```

To check the application DR status run:

```
kubectl get drpc deployment-rbd-drpc -n ramen-ops --context hub -o wide
```

Example output:

```
NAME                  AGE   PREFERREDCLUSTER   FAILOVERCLUSTER   DESIREDSTATE   CURRENTSTATE   PROGRESSION   START TIME             DURATION          PEER READY
deployment-rbd-drpc   28m   dr1                dr2               Failover       FailedOver     Completed     2024-06-04T18:10:44Z   11m24.41686883s   True
```

The failover has completed, and the application data is replicated again
to the primary cluster.

### Relocate the sample application

To move the application back to the primary cluster after a disaster you
can use the `Relocate` action. You will delete the application on the
secondary cluster, and *Ramen* will start it on the primary cluster. No
data is lost during this operation.

To start the relocate operation, patch the application
`DRPlacementControl` resource in the `ramen-ops` namespace on the hub.
We need to set `action` and if needed, `preferredCluster`:

```
kubectl patch drpc deployment-rbd-drpc \
    --patch '{"spec": {"action": "Relocate", "preferredCluster": "dr1"}}' \
    --type merge \
    --namespace ramen-ops \
    --context hub
```

*Ramen* will prepare for relocation, and proceed until the point the
application should be deleted from the cluster. To watch the progress
run:

```
kubectl get drpc deployment-rbd-drpc -n ramen-ops --context hub -o wide -w
```

Example output:

```
NAME                  AGE   PREFERREDCLUSTER   FAILOVERCLUSTER   DESIREDSTATE   CURRENTSTATE   PROGRESSION          START TIME             DURATION   PEER READY
deployment-rbd-drpc   91m   dr1                dr2               Relocate       Initiating     PreparingFinalSync   2024-06-04T19:25:52Z              True
deployment-rbd-drpc   92m   dr1                dr2               Relocate       Relocating     RunningFinalSync     2024-06-04T19:25:52Z              True
deployment-rbd-drpc   92m   dr1                dr2               Relocate       Relocating     WaitOnUserToCleanUp   2024-06-04T19:25:52Z              False
```

When ramen shows the progression `WaitOnUserToCleanUp` you need to
delete the application from the secondary cluster:

```
kubectl delete -k workloads/deployment/k8s-regional-rbd -n deployment-rbd --context dr2
```

At this pint *Ramen* will proceed with starting the application on the
primary cluster, and setting up replication to the secondary cluster.

To wait until the application is relocated to the primary cluster, run:

```
kubectl wait drpc deployment-rbd-drpc \
    --for jsonpath='{.status.phase}=Relocated' \
    --namespace ramen-ops \
    --timeout 5m \
    --context hub
```

To wait until the application is replicating data again to the secondary
cluster, wait for the `Protected` condition:

```
kubectl wait drpc deployment-rbd-drpc \
    --for condition=Protected \
    --namespace ramen-ops \
    --timeout 5m \
    --context hub
```

To check the application DR status run:

```
kubectl get drpc deployment-rbd-drpc -n ramen-ops --context hub -o wide
```

Example output:

```
NAME                  AGE    PREFERREDCLUSTER   FAILOVERCLUSTER   DESIREDSTATE   CURRENTSTATE   PROGRESSION   START TIME             DURATION          PEER READY
deployment-rbd-drpc   103m   dr1                dr2               Relocate       Relocated      Completed     2024-06-04T19:25:52Z   3m46.040128192s   True
```

The relocate has completed, and the application data is replicated again
to the secondary cluster.

### Disable DR for the sample application

Since OCM is not managing the application, we can simply delete the DR
resources:

```
kubectl delete -k dr/discovered/deployment-rbd --context hub
```

This deletes the DR resources, disable replication and delete the
replicated data on the secondary cluster.

The application is still running on the primary cluster:

```
kubectl get deploy,pod,pvc -n deployment-rbd --context dr1
```

Example output:

```
NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/busybox   1/1     1            1           16m

NAME                           READY   STATUS    RESTARTS   AGE
pod/busybox-6bbf88b9f8-fz2kn   1/1     Running   0          16m

NAME                                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/busybox-pvc   Bound    pvc-c45a3892-167b-4dbc-a250-09c5f288c766   1Gi        RWO            rook-ceph-block   <unset>                 16m
```

### Undeploy the sample application

Delete the application workload from the cluster:

```
kubectl delete -k workloads/deployment/k8s-regional-rbd -n deployment-rbd --context dr1
```
