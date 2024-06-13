# Disaster recovery terms

## Regional-DR

*Ramen* can protect applications running on clusters in different
regions, using cluster storage solution. *Ramen* sets up volume
replication between the remote clusters, replicating data written on the
primary cluster to the secondary cluster. If needed, the application can
be relocated to the secondary cluster and back, using the replicated
data.

## Metro-DR

*Ramen* can protect application running on clusters in the same region,
sharing a storage solution stretched across the clusters. If needed the
application can be relocated from the primary cluster to the secondary
cluster and back.

## OCM managed applications

*Ramen* can protect applications managed by *OCM*, using *GitOps*. When
DR is enabled for an application, *Ramen* controls the application
placement and set up volume replication to protect the application data.
When relocating to another cluster, *OCM* deletes the application from
the cluster and deploys it on the other cluster.

## OCM discovered applications

*Ramen* can protect any application deployed directly on a cluster
without *OCM*.  When DR is enabled for an application, *Ramen* controls
the application placement, sets up volume replication to protect the
application data, and backs up application resources.

When relocating the application to another cluster, *Ramen* deploys the
application on the other cluster by restoring the application resources
from backup.  However to complete the operation, the user must delete
the application from the cluster since *Ramen* does not support deleting
application resources.

## Storage type

*Ramen* is designed to protect any
[Container Storage Interface (CSI)](https://github.com/container-storage-interface/spec/blob/master/spec.md)
volume supporting the [Volume Replication](https://github.com/csi-addons/volume-replication-operator)
*CSI* addon, or [Volume snapshot](https://kubernetes.io/docs/concepts/storage/volume-snapshots/).
*Ramen* is tested with [Rook Ceph](https://rook.io/) storage, with both
*Ceph RDB* block volumes (RWO) and *CephFS* shared filesystem volumes (RWX).
