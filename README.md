# minimal-script
One script which generates fully functional live Linux ISO image with minimal effort. This is based on the first published version of [Minimal Linux Live](http://github.com/ivandavidov/minimal). All comments and empty lines have been removed and the original script code has been slightly altered to reduce the overall script length.

The script below uses **Linux kernel 3.15.6** and **BusyBox 1.22.1**. If you are using [Ubuntu](http://ubuntu.com) or [Linux Mint](http://linuxmint.com), you should be able to resolve all build dependencies by executing the following command:

```
sudo apt-get install wget bc build-essential gawk syslinux genisoimage
```

After that simply run the below script. In the end you should have a bootable ISO image named `minimal_linux_live.iso` in the same directory where you executed the script.

```
rm -rf work
mkdir work
cd work
rm -f linux-3.15.6.tar.xz
wget http://kernel.org/pub/linux/kernel/v3.x/linux-3.15.6.tar.xz
rm -rf kernel
mkdir kernel
tar -xvf linux-3.15.6.tar.xz -C kernel
cd kernel/linux-3.15.6
make clean defconfig vmlinux
cd ../..
rm -f busybox-1.22.1.tar.bz2
wget http://busybox.net/downloads/busybox-1.22.1.tar.bz2
rm -rf busybox
mkdir busybox
tar -xvf busybox-1.22.1.tar.bz2 -C busybox
cd busybox/busybox-1.22.1
make clean defconfig
sed -i "s/.*CONFIG_STATIC.*/CONFIG_STATIC=y/" .config
make busybox install
rm -rf ../../rootfs
cp -R _install ../../rootfs
cd ../../rootfs
rm -f linuxrc
mkdir dev etc proc sys tmp
cd etc
echo > welcome.txt
echo '  #####################################' >> welcome.txt
echo '  #                                   #' >> welcome.txt
echo '  #  Welcome to "Minimal Linux Live"  #' >> welcome.txt
echo '  #                                   #' >> welcome.txt
echo '  #####################################' >> welcome.txt
echo >> welcome.txt
cd ..
echo '#!/bin/sh' > init
echo 'dmesg -n 1' >> init
echo 'mount -t devtmpfs none /dev' >> init
echo 'mount -t proc none /proc' >> init
echo 'mount -t sysfs none /sys' >> init
echo 'cat /etc/welcome.txt' >> init
echo 'while true' >> init
echo 'do' >> init
echo '  setsid cttyhack /bin/sh' >> init
echo 'done' >> init
echo >> init
chmod +x init
rm -f ../rootfs.cpio.gz
cd ../rootfs
find . | cpio -H newc -o | gzip > ../rootfs.cpio.gz
rm -f ../../minimal_linux_live.iso
cd ../kernel/linux-3.15.6
make isoimage FDINITRD=../../rootfs.cpio.gz
cp arch/x86/boot/image.iso ../../../minimal_linux_live.iso
cd ../../..
```

Note that this produces very small live Linux OS with almost no useful functionality (apart from working shell) and no proper network support. The network support has been handled properly in the [Minimal Linux Live](http://github.com/ivandavidov/minimal) project which is extensively documented and more feature rich, yet still produces very small live Linux ISO image.
