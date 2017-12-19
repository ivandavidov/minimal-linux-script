#!/bin/sh
set -ex
KERNEL_VERSION=4.12.3
BUSYBOX_VERSION=1.27.1
SYSLINUX_VERSION=6.03
if [ ! -e kernel.tar.xz ];then
wget -O kernel.tar.xz https://kernel.org/pub/linux/kernel/v4.x/linux-$KERNEL_VERSION.tar.xz
fi
if [ ! -e busybox.tar.bz2 ];then
wget -O busybox.tar.bz2 https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
fi
if [ ! -e syslinux.tar.xz ];then
wget -O syslinux.tar.xz https://kernel.org/pub/linux/utils/boot/syslinux/syslinux-$SYSLINUX_VERSION.tar.xz
fi
tar -xvf kernel.tar.xz
tar -xvf busybox.tar.bz2
tar -xvf syslinux.tar.xz
mkdir isoimage
cd busybox-$BUSYBOX_VERSION
make distclean defconfig
sed -i "s/.*CONFIG_STATIC.*/CONFIG_STATIC=y/" .config
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
cd ../../linux-$KERNEL_VERSION
make mrproper defconfig bzImage
cp arch/x86/boot/bzImage ../isoimage/kernel.gz
cd ../isoimage
cp ../syslinux-$SYSLINUX_VERSION/bios/core/isolinux.bin .
cp ../syslinux-$SYSLINUX_VERSION/bios/com32/elflink/ldlinux/ldlinux.c32 .
echo 'default kernel.gz initrd=rootfs.gz' > ./isolinux.cfg
genisoimage \
    -J \
    -r \
    -o ../minimal_linux_live.iso \
    -b isolinux.bin \
    -c boot.cat \
    -input-charset UTF-8 \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -joliet-long \
    ./
cd ..
set +ex

