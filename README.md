# ocm-ramen-samples

OCM Stateful application samples, including *Ramen* resources.

## Create an environment

The easiest way to start is to use the *Ramen* testing environment
created by the *drenv* tool. See [drenv](drenv.md) to learn how to
quickly create a your disaster recovery playground.

## Initial setup

Before experimenting with disaster recovery we need to configure the
clusters. See [initial setup](docs/initial-setup.md) to learn how to set
up your environment.

## Experiments

After setting up your environment you can experiments with various
workloads and storage types:

- Experiment with *OCM* managed applications using [RBD](docs/ocm-rbd.md) or
  [CephFS](docs/ocm-cephfs.md) storage.

- Experiment with discovered applications using [RBD](docs/discovered-rbd.md)
  or [CephFS](docs/discovered-cephfs.md) storage.

- Experiment with [OCM managed](docs/ocm-kubevirt.md) or
  [discovered](docs/discovered-kubevirt.md) virtual machines using *RBD*
  storage.
