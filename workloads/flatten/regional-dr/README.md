# Flattening sample for regional-dr environment

This sample creates a deployment using a pvc restored from a snapshot.

Using volume replication class with flattening enabled, this workload
can be protected by ramen.

## Setup

```
./create-golden-image
./create-deployment
```

## Testing DR

Protect the deployemnt:

```
./protect-deployment
```

This will fail if the dr policy is not enabled for DR.

Unprotect the deployment:

```
./unprotect-deployment
```

## Cleanup

```
./delete-deployment
./delete-golden-image
```
