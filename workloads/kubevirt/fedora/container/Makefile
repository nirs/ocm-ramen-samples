VER := 2
IMG := quay.io/nirsof/dr-demo:fedora-$(VER)

base_image := https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2

container: fedora.qcow2
	podman build -t $(IMG) .

push:
	podman push $(IMG)

fedora.qcow2: customized.qcow2
	qemu-img convert -p -f qcow2 -O qcow2 -c -W $^ $@

customized.qcow2: base.qcow2
	qemu-img create -f qcow2 -b base.qcow2 -F qcow2 tmp.qcow2
	genisoimage -o extra.iso -R -J -V EXTRA extra
	virt-install \
		--import \
		--name fedora \
		--ram 2048 \
		--cpus 2 \
		--disk path=tmp.qcow2,format=qcow2 \
		--disk path=extra.iso,device=cdrom \
		--os-variant fedora40 \
		--cloud-init user-data=user-data.yaml,disable=off
	virsh undefine fedora
	mv tmp.qcow2 customized.qcow2

base.qcow2:
	curl -L -o $@ $(base_image)

clean:
	rm -f *.iso *.qcow2
