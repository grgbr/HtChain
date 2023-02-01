#!/bin/sh -e

qemu-system-x86_64 -cpu host \
                   -accel kvm \
                   -smp cpus=8 \
		   -machine q35 \
		   -m 4G \
		   -nodefaults \
		   -audiodev id=none,driver=none \
		   -nic none \
		   -nographic \
		   -serial mon:stdio
