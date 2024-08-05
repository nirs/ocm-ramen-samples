VER := 1
IMG := quay.io/nirsof/dr-demo:fedora-$(VER)

container: fedora.qcow2
	podman build -t $(IMG) .

push:
	podman push $(IMG)

fedora.qcow2:
	genisoimage -o extra.iso -R -J -V EXTRA extra
	LIBGUESTFS_BACKEND=direct virt-builder fedora-40 \
		--output fedora.raw \
		--hostname=fedora \
		--ssh-inject=root \
		--root-password=password:root \
		--selinux-relabel \
		--install=qemu-guest-agent \
		--attach extra.iso \
		--run extra.sh \
		--firstboot firstboot.sh
	qemu-img convert -p -f raw -O qcow2 -c -W fedora.raw fedora.qcow2
	rm -f fedora.raw

# Create libvirt vm for testing the image. Using an overlay so we don't modify
# the actual image.
vm:
	qemu-img create -f qcow2 -b fedora.qcow2 -F qcow2 overlay.qcow2
	virt-install \
		--connect qemu:///system \
		--import \
		--name fedora \
		--ram 2048 \
		--cpus 2 \
		--disk path=overlay.qcow2,format=qcow2 \
		--os-variant fedora40

clean:
	rm -f *.iso *.raw *.qcow2
