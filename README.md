# iohyve
FreeBSD bhyve manager utilizing ZFS and other FreeBSD tools. 

iohyve creates, stores, manages, and launches bhyve guests utilizing built in FreeBSD features including virtio drivers and ZFS. 
iohyve strives to be much like @pannon's iocage, storing properties in ZFS datasets. [https://github.com/iocage/iocage]
There is currently support for VIMAGE/VNET just as iocage. Documentation soon to come. For more information on VNET support, run:

    iohyve readme

Or create a readme file:

    iohyve readme > readme.txt 

Don't forget to check out the built in man page!

    iohyve man 

**Pre-Flight Checklist**

[Taken from the FreeBSD handbook https://www.freebsd.org/doc/en/books/handbook/virtualization-host-bhyve.html]
The first step to creating a virtual machine in bhyve is configuring the host system. First, load the bhyve kernel module:

    kldload vmm
    kldload nmdm

Then, create a tap interface for the network device in the virtual machine to attach to. In order for the network device to participate in the network, also create a bridge interface containing the tap 
interface ane the physical interface as members. In this example, the physical interface is igb0:

    ifconfig tap0 create
    sysctl net.link.tap.up_on_open=1
        net.link.tap.up_on_open: 0 -> 1
    ifconfig bridge0 create
    ifconfig bridge0 addm igb0 addm tap0
    ifconfig bridge0 up

The built-in readme 'iohyve readme' has more information on VNET setups. 

**Usage**

    iohyve  
        version
        setup [pool]
        list
        isolist
        vmmlist
        running
        fetch [URL]
        remove [ISO]
        create [name] [size] [console]
        install [name] [ISO]
        load [name]
        boot [name] [ISO]
        start [name]
        stop [name]
        off [name]
        scram
        destroy [name]
        delete [name]
        set [name] [prop=value]
        get [name] [prop]
        getall [name]
        conlist
        console [name]
        readme
        help
        man 

**Setup**

Setup iohyve by telling it what zpool to use

    iohyve setup tank

**General Usage**

List all guests created with:

    iohyve list

List all guests that have resources allocated using:

    iohyve vmmlist

List all runnng guests using:

    iohvye running

You can change guest properties by using set:

    iohyve bsdguest set ram=512M    #set ram to 512 Megabytes
    iohyve bsdguest set cpu=1       #set cpus to 1 core
    iohyve bsdguest set tap=tap0    #set tap device for ethernet
    iohyve bsdguest set con=nmdm0   #set the console to attach to

Get a specific guest property:

    iohyve get bsdguest ram

Get all guest properties:

    iohyve getall bsdguest

**FreeBSD Guests**

Fetch FreeBSD install ISO for later:

    iohyve fetch ftp://ftp.freebsd.org/.../10.1/FreeBSD-10.1-RELEASE-amd64-bootonly.iso

Create a new FreeBSD guest named bsdguest on console nmdm0 with an 8Gigabyte virtual HDD:

    iohyve create bsdguest 8G nmdm0

List ISO's:

    iohyve isolist

Install the FreeBSD guest bsdguest:

    iohyve install bsdguest FreeBSD-10.1-RELEASE-amd64-bootonly.iso

Console into the intallation:

    iohyve console bsdguest

Once installation is done, exit console (~~.) and destroy guest:

    iohyve destroy bsdguest

Now that the guest is installed, it can be started like usual:

    iohyve start bsdguest

Some guest os's (Like FreeBSD and Debian Linux Distros) can be gracefully stopped:

    iohyve stop bsdguest

FreeBSD guests can now persist after the guest reboots or shutdowns. This means if you reboot the guest from console, it 
will come back up without having to start manually. As of version 2.12, guests still don't persist after host reboot.

This is done by simply appending '-p &' to the end of the start command:

    iohyve start bsdguest -p &

**Debian based distros like Ubuntu and obviously Debian:**

Fetch Linux ISO:

    iohyve fetch http://cdimage.debian.org/.../debian-8.0.0-amd64-netinst.iso

Create linux guest:

    iohyve create jessie 8G nmdm1

Set correct properties for linux guest:

    iohyve set jessie loader=grub   # Sets correct bootloader
    iohyve set jessie os=debian     # Sets correct OS type

Attach ISO and load installer from ISO:

    iohyve install jessie debian-8.0.0-amd64-netinst.iso    # loads grub

Console into grub loader to boot: (once OS is chosen, ~~. to exit)

    iohyve console jessie

Boot into installation ISO:

    iohyve boot jessie debian-8.0.0-amd64-netinst.iso

Console into guest and set up: (~~. to exit)

    iohvye console jessie

Destroy linux guest before booting without installation ISO:

    iohyve destroy jessie

Start linux guest like normal:

    iohyve start jessie

**CentOS 6 Guests**

Fetch CentOS 6 ISO

    iohyve fetch http://centos.escapemg.com/.../CentOS-6.6-x86_64-netinstall.iso

Create CentOS 6 guest:

    iohyve create centos6 16G nmdm6

Set correct properties:

    iohyve set centos6 ram=512M     # Min Sys Requirements
    iohyve set centos6 loader=grub  # Grub loader
    iohyve set centos6 os=centos6   # OS type
 
Attach ISO and load installer:

    iohyve install centos6 CentOS-6.6-x86_64-netinstall.iso
 
Console into guest:

    iohyve console centos6
 
In the grub console:

    grub> ls (cd0)/isolinux/                # list isolinux directory
    boot.cat boot.msg grub.conf initrd.img isolinux.bin isolinux.cfg memtest splash
    .jpg TRANS.TBL vesamenu.c32 vmlinuz
    grub> linux (cd0)/isolinux/vmlinuz      # load kernel
    grub> initrd (cd0)/isolinux/initrd.img  # ramfs
    grub> boot                              # boot machine
    ~~.                                     # exit from console
 
Boot into the installation ISO:

    iohyve boot centos6 CentOS-6.6-x86_64-netinstall.iso

Console into the guest and install the it:

     iohyve console centos6

Destroy guest:

    iohyve destory centos6
  
Load the centos6 guest:

    iohyve load centos6

Console into booloader:

    iohyve console centos6

Find kernel and ramfs:

    grub>ls (hd0,msdos1)/
    lost+found/ grub/ efi/ System.map-2.6.32-504.el6.x86_64 config-2.6.32-504.el6.x
    86_64 symvers-2.6.32-504.el6.x86_64.gz vmlinuz-2.6.32-504.el6.x86_64 initramfs-
    2.6.32-504.el6.x86_64.img
    grub>linux (hd0,msdos1)/vmlinuz-2.6.32-504.el6.x86_64 root=/dev/mapper/VolGroup-lv_root
    grub>initrd (hd0,msdos1)/initramfs-2.6.32-504.el6.x86_64.img
    grub>boot
    ~~.

Boot the OS:

    iohyve boot centos6

Console into the OS:

    iohyve console centos6

Log into root and install grub2:

    [root@localhost ~]# yum install wget bison gcc flex nano
    [root@localhost ~]# wget ftp://ftp.gnu.org/gnu/grub/grub-2.00.tar.gz
    [root@localhost ~]# tar -xzf grub-2.00.tar.gz
    [root@localhost ~]# cd grub-2.00
    [root@localhost grub-2.00]# ./configure    
    [root@localhost grub-2.00]# make install
    [root@localhost grub-2.00]# /usr/local/sbin/grub-mkconfig -o /boot/grub/grub.cfg
    [root@localhost grub-2.00]# /usr/local/sbin/grub-install /dev/vda
    [root@localhost grub-2.00]# init 0

Destory guest:

    iohyve destroy centos6

Start CentOS 6 guest:

    iohyve start centos6
