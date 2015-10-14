# iohyve v0.6
"Multiple Disk Disorder Edition"

FreeBSD bhyve manager utilizing ZFS and other FreeBSD tools. 
*Over the hill to 1.0*

iohyve creates, stores, manages, and launches bhyve guests utilizing built in FreeBSD features. 
The idea is based on iocage, a jail manager utilizing some of the same principles. 


DO YOU EVEN MAN PAGE?

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

Once you have created tap0, there is no need to create more tap interfaces for iohyve, it will create them and add them 
to bridge0 automatically as of v0.3.2 master branch.

The built-in readme 'iohyve readme' has more information on VNET setups. 

**Usage**

```
iohyve  version
        setup [pool]
        list
        isolist
        vmmlist
        running
        fetch [URL]
        renameiso [ISO] [newname]
        remove [ISO]
        create [name] [size]
        install [name] [ISO]
        load [name] [path/to/bootdisk]
        boot [name] [runmode] [pcidevices]
        start [name] [-s | -a]
        stop [name]
        scram
        destroy [name]
        rename [name] [newname]
        delete [name]
        set [name] [prop=value]
        get [name] [prop]
        getall [name]
        taplist
        activetaps
        conlist
        activecons
        console [name]
        conreset
        readme
        help
        man 
```

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

    iohyve set bsdguest ram=512M                 #set ram to 512 Megabytes
    iohyve set bsdguest cpu=1                    #set cpus to 1 core
    iohyve set bsdguest tap=tap0                 #set tap device for ethernet
    iohyve set bsdguest con=nmdm0                #set the console to attach to
    iohyve set bsdguest pcidev:1=passthru,2/0/0  #pass through a pci device

Get a specific guest property:

    iohyve get bsdguest ram

Get all guest properties:

    iohyve getall bsdguest

Take a snapshot of a guest:
````
iohyve snapguest bsdguest@beforeupdate  #take snapshot
iohyve snaplist                         #list snapshots
iohyve snapguest bsdguest@beforeupdate  #rollback to snapshot
````
**FreeBSD Guests**

Fetch FreeBSD install ISO for later:

    iohyve fetch ftp://ftp.freebsd.org/.../10.1/FreeBSD-10.1-RELEASE-amd64-bootonly.iso

Rename the ISO if you would like:

    iohyve renameiso FreeBSD-10.1-RELEASE-amd64-bootonly.iso fbsd10.iso

Create a new FreeBSD guest named bsdguest with an 8Gigabyte virtual HDD:

    iohyve create bsdguest 8G

List ISO's:

    iohyve isolist

Install the FreeBSD guest bsdguest:

    iohyve install bsdguest FreeBSD-10.1-RELEASE-amd64-bootonly.iso

Console into the intallation:

    iohyve console bsdguest

Once installation is done, exit console (~~.) and stop guest:

    iohyve stop bsdguest

Now that the guest is installed, it can be started like usual:

    iohyve start bsdguest

Some guest os's can be gracefully stopped:

    iohyve stop bsdguest

**Other BSDs:**

Try out OpenBSD:
````
iohyve set obsdguest loader=grub-bhyve
iohyve set obsdguest os=openbsd
iohyve install obsdguest install57.iso
iohyve console obsdguest
````
Try out NetBSD:
````
iohyve set nbsdguest loader=grub-bhyve
iohyve set nbsdguest os=netbsd
iohyve install nbsdguest NetBSD-6.1.5-amd64.iso
iohyve console nbsdguest
````
**Linux flavors:**

Try out Debian or Ubuntu:
````
iohyve set debguest loader=grub-bhyve
iohyve set debguest os=debian
iohyve install debguest debian-8.2.0-amd64-i386-netinst.iso
iohyve console debguest
````
Try out ArchLinux:
````
iohyve set archguest loader=grub-bhyve
iohyve set archguest os=arch
iohyve install archguest archlinux-2015.10.01-dual.iso
iohyve console archguest
````
Try out CentOS 6:
````
iohyve set centguest loader=grub-bhyve
iohyve set centguest os=centos6
iohyve set centguest ram=512M			# CentOS6 Requirement
iohyve install centguest CentOS-6.7-x86_64-netinstall.iso

# Okay whoa, hold on, we can go two ways here. 
# There the hacky way, and the more hacky way. 
# Option 1: Update a property everytime the kernel is updated. 
# Option 2: Do some things, compile things, not worry so much. 

# Option 1:
iohyve set centguest os=custom 			# Do this once
iohyve set centguest autogrub='linux%1s(hd0,msdos1)/vmlinuz-2.6.32-573.el6.x86_64%1sroot=/dev/mapper/VolGroup-lv_root\ninitrd%1s(hd0,msdos1)/initramfs-2.6.32-573.el6.x86_64.img\nboot\n'
# I know, right? Do that everytime you update your Linus kernel. 

# Option 2:
iohyve set centguest os=default
iohyve start centguest				# Do some things
iohyve console centos guest			

# Find the kernel and things to boot the first time. 

grub>ls (hd0,msdos1)/ 
lost+found/ grub/ efi/ System.map-2.6.32-504.el6.x86_64 config-2.6.32-504.el6.x
86_64 symvers-2.6.32-504.el6.x86_64.gz vmlinuz-2.6.32-504.el6.x86_64 initramfs-
2.6.32-504.el6.x86_64.img
grub>linux (hd0,msdos1)/vmlinuz-2.6.32-504.el6.x86_64 root=/dev/mapper/VolGroup-lv_root
grub>initrd (hd0,msdos1)/initramfs-2.6.32-504.el6.x86_64.img
grub>boot

# Stuff may scroll across screen

CentOS release 6.7 (Final)
Kernel 2.6.32-573.el6.x86_64 on an x86_64	# Don't panic

localhost.localdomain login: root		# Okay panic a little

# Install Grub2

[root@localhost ~]# yum install wget bison gcc flex nano
[root@localhost ~]# wget ftp://ftp.gnu.org/gnu/grub/grub-2.00.tar.gz
[root@localhost ~]# tar -xzf grub-2.00.tar.gz
[root@localhost ~]# cd grub-2.00
[root@localhost grub-2.00]# ./configure    
[root@localhost grub-2.00]# make install
[root@localhost grub-2.00]# /usr/local/sbin/grub-mkconfig -o /boot/grub/grub.cfg
[root@localhost grub-2.00]# /usr/local/sbin/grub-install /dev/sda
[root@localhost grub-2.00]# init 0

# Exit the terminal (To make sure) [Enter] [Enter] (~ ~ .)

iohyve destroy centos				# Double tap

iohyve set centos6 os=centos6			# Set it back.

iohyve start centos				# "Should" work. 


````
