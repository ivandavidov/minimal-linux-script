# Minimal Linux Script

![Minimal Linux Script](http://minimal.idzona.com/mls/minimal_linux_script.png)

One script which generates fully functional live Linux ISO image with minimal effort. This is based on the first published version of [Minimal Linux Live](http://github.com/ivandavidov/minimal) with some improvements taken from the next releases. All empty lines and comments have been removed and the script has been modified to reduce the overall length.

The script below uses **Linux kernel 4.8**, **BusyBox 1.24.2** and **Syslinux 6.03**. The source bundles are downloaded and compiled automatically. If you are using [Ubuntu](http://ubuntu.com) or [Linux Mint](http://linuxmint.com), you should be able to resolve all build dependencies by executing the following command:

    sudo apt-get install wget bc build-essential gawk genisoimage

After that simply run the below script. It doesn't require root privileges. In the end you should have a bootable ISO image named `minimal_linux_live.iso` in the same directory where you executed the script.

    wget http://kernel.org/pub/linux/kernel/v4.x/linux-4.8.tar.xz
    wget http://busybox.net/downloads/busybox-1.24.2.tar.bz2
    wget http://kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.xz
    mkdir isoimage
    tar -xvf linux-4.8.tar.xz
    tar -xvf busybox-1.24.2.tar.bz2
    tar -xvf syslinux-6.03.tar.xz
    cd busybox-1.24.2
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
    cd ../../linux-4.8
    make mrproper defconfig bzImage
    cp arch/x86/boot/bzImage ../isoimage/kernel.gz
    cd ../isoimage
    cp ../syslinux-6.03/bios/core/isolinux.bin .
    cp ../syslinux-6.03/bios/com32/elflink/ldlinux/ldlinux.c32 .
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

Note that this script produces very small live Linux OS with working shell only and no network support. The network functionality has been implemented properly in the [Minimal Linux Live](http://github.com/ivandavidov/minimal) project which is extensively documented and more feature rich, yet still produces very small live Linux ISO image.
