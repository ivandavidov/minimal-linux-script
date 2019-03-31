#!/bin/sh
set -ex
KERNEL_VERSION=5.0.2
BUSYBOX_VERSION=1.30.1
SYSLINUX_VERSION=6.03
KERNEL_MD5=911065be61e90bc9afefd2c0ffa944c1
BUSYBOX_MD5=4f72fc6abd736d5f4741fc4a2485547a
SYSLINUX_MD5=92a253df9211e9c20172796ecf388f13
echo "$KERNEL_MD5 kernel.tar.xz" | md5sum -c ||
wget -O kernel.tar.xz http://kernel.org/pub/linux/kernel/v5.x/linux-${KERNEL_VERSION}.tar.xz
echo "$BUSYBOX_MD5 busybox.tar.bz2" | md5sum -c ||
wget -O busybox.tar.bz2 http://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2
echo "$SYSLINUX_MD5 syslinux.tar.xz" | md5sum -c ||
wget -O syslinux.tar.xz http://kernel.org/pub/linux/utils/boot/syslinux/syslinux-${SYSLINUX_VERSION}.tar.xz
tar -xvf kernel.tar.xz
tar -xvf busybox.tar.bz2
tar -xvf syslinux.tar.xz
mkdir -p isoimage
cd busybox-${BUSYBOX_VERSION}
make distclean defconfig
sed -i "s|.*CONFIG_STATIC.*|CONFIG_STATIC=y|" .config
make busybox install
cd _install
rm -f linuxrc
mkdir dev proc sys
echo '#!/bin/sh' > init
echo 'dmesg -n 1' >> init
echo 'mount -t devtmpfs none /dev' >> init
echo 'mount -t proc none /proc' >> init
echo 'mount -t sysfs none /sys' >> init
echo 'setsid cttyhack /bin/sh' >> init
chmod +x init
find . | cpio -R root:root -H newc -o | gzip > ../../isoimage/rootfs.gz
cd ../../linux-${KERNEL_VERSION}
make mrproper defconfig bzImage
cp arch/x86/boot/bzImage ../isoimage/kernel.gz
cd ../isoimage
cp ../syslinux-${SYSLINUX_VERSION}/bios/core/isolinux.bin .
cp ../syslinux-${SYSLINUX_VERSION}/bios/com32/elflink/ldlinux/ldlinux.c32 .
echo 'default kernel.gz initrd=rootfs.gz' > ./isolinux.cfg
xorriso \
  -as mkisofs \
  -o ../minimal_linux_live.iso \
  -b isolinux.bin \
  -c boot.cat \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  ./
cd ..
set +ex
