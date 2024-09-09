# Flattening sample for regional-dr-kubevirt environment

This sample creates a vm using a volume snapshot.

Using volume replication class with flattening enabled, this vm can be
protected by ramen.

## Setup

```
./create-cirros
./create-vm
```

## Testing DR

Protect the vm:

```
./protect-vm
```

This will fail if the dr policy is not enabled for DR.

Unprotect the vm:

```
./unprotect-vm
```

## Cleanup

```
./delete-vm
./delete-cirros
```
