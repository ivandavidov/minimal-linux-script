# Minimal Linux Script
One script which generates fully functional live Linux ISO image with minimal effort (less than 30 lines of code). This is based on the first published version of [Minimal Linux Live](http://github.com/ivandavidov/minimal) with some minor improvements taken from the next releases. All empty lines and comments have been removed and the script has been modified to reduce the overall length.

The script below uses **Linux kernel 4.6.2** and **BusyBox 1.24.2**. The source bundles are downloaded and compiled automatically. If you are using [Ubuntu](http://ubuntu.com) or [Linux Mint](http://linuxmint.com), you should be able to resolve all build dependencies by executing the following command:

    sudo apt-get install wget bc build-essential gawk syslinux genisoimage

After that simply run the below script. It doesn't require root privileges. In the end you should have a bootable ISO image named `minimal_linux_live.iso` in the same directory where you executed the script.

    wget http://kernel.org/pub/linux/kernel/v4.x/linux-4.6.2.tar.xz
    tar -xvf linux-4.6.2.tar.xz
    cd linux-4.6.2
    make mrproper defconfig bzImage
    cd ..
    wget http://busybox.net/downloads/busybox-1.24.2.tar.bz2
    tar -xvf busybox-1.24.2.tar.bz2
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
    find . | cpio -R root:root -H newc -o | gzip > ../../rootfs.cpio.gz
    cd ../../linux-4.6.2
    make isoimage FDINITRD=../rootfs.cpio.gz
    cp arch/x86/boot/image.iso ../minimal_linux_live.iso
    cd ..

Note that this produces very small live Linux OS with working shell only. The network support has been implemented properly in the [Minimal Linux Live](http://github.com/ivandavidov/minimal) project which is extensively documented and more feature rich, yet still produces very small live Linux ISO image.
