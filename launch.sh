#!/bin/bash

cd src
make
cd ..
cp src/*.ko fs/

pushd fs
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../../initramfs.cpio.gz
popd

/usr/bin/qemu-system-x86_64 \
	-kernel linux-5.4/arch/x86/boot/bzImage \
	-initrd $PWD/initramfs.cpio.gz \
	-fsdev local,security_model=passthrough,id=fsdev0,path=$PWD \
	-device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare \
	-nographic \
	-monitor none \
	-s \
	-append "console=ttyS0 nokaslr"
