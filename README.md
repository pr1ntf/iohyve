# iohyve v0.7
"I'm Here for the Party Edition"

FreeBSD bhyve manager utilizing ZFS and other FreeBSD tools. 
*Over the hill to 1.0*

iohyve creates, stores, manages, and launches bhyve guests utilizing built in FreeBSD features. 
The idea is based on iocage, a jail manager utilizing some of the same principles. 


DO YOU EVEN MAN PAGE?
````
man iohyve			# Installs with 'make install'

cat iohyve.8.txt | less		# Quick and dirty txt file
````

**Pre-Flight Checklist**

As of v0.7 `iohyve` takes care of setting up your machine if you let it. 
Once you have created your ZFS pool named 'tank' you can run:
````
iohyve setup pool=tank
````
If you want `iohyve` to take care of networking, so you don't have to set up `rc.conf` you can do the following:
````
iohyve setup net=em0		# 'em0' is the interface I want bridge0 attached to.
````
You can even have `iohyve` load the required kernel modules:
````
iohyve setup kmod=1
````
You can also do all of the above at once:
````
iohyve setup pool=tank kmod=1 net=em0
````
If you want `iohyve` to set up the kernel modules and bridge0 every time you boot, add these lines to `/etc/rc.conf`:
````
iohyve_enable="YES"
iohyve_flags="kmod=1 net=em0"
````

If you want more control over your setup, feel free to read the [handbook](https://www.freebsd.org/doc/en/books/handbook/virtualization-host-bhyve.html).


**Usage**

```
iohyve  

version
setup pool=[poolname] kmod=[0/1] net=[interface]
list
info [-d]
isolist
fwlist
fetch [URL]
cpiso [path]
renameiso [ISO] [newname]
rmiso [ISO]
fetchfw [URL]
cpfw [path]
renamefw [firmware] [newname]
rmfw [firmware]
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
add [name] [size]
remove [name] [diskN]
resize [name] [diskN] [size]
disks [name]
snap [name]@[snapshotname]
roll [name]@[snapshotname]
clone [name] [clonename]
snaplist
taplist
activetaps
conlist
console [name]
conreset
help
```
**Quick note about upgrading from v0.6.0 to v0.6.5 and above**


iohyve can now set custom bhyve flags when launching guests. Instead of being stuck with the default
I set up as `bhyve -A -H -P etc...` you can now edit those flags using the `bargs` property. 

For instance, if you want the bhyve RTC to use UTC time, do the following:
````
iohyve set bsdguest bargs="-A -H -P -u"
````
Note that you must put your arguments inbetween double quotes ("). iohyve will take care of the rest. 

As to not break guests created before v6.5, iohyve will still launch with defaults, but will throw the error:
````
iohyve start bsdguest
Starting bsdguest... (Takes 15 seconds for FreeBSD guests)
This version of your guest is outdated.
Please run iohyve fix-bargs guestname to update.
````
To set default arguments, I have added the `fix-bargs` function. Simply run `iohyve fix-bargs bsdguest`
and iohyve will set a default. 

**General Usage**

List all guests created with:

    iohyve list

You can change guest properties by using set:

    iohyve set bsdguest ram=512M                 #set ram to 512 Megabytes
    iohyve set bsdguest cpu=1                    #set cpus to 1 core
    iohyve set bsdguest tap=tap0                 #set tap device for ethernet
    iohyve set bsdguest con=nmdm0                #set the console to attach to
    iohyve set bsdguest pcidev:1=passthru,2/0/0  #pass through a pci device

You can also set a description that can be a double quoted (") string with no equals sign (=). 
All spaces are turned into underscores (_). At guest creation, the description is the output of `date`
````
iohyve set bsdguest description="This is my string"
````

Get a specific guest property:

    iohyve get bsdguest ram

Get all guest properties:

    iohyve getall bsdguest

Do cool ZFS stuff to a guest:
````
#Take a snapshot of a guest. 
iohyve snap bsdguest@beforeupdate  #take snapshot
iohyve snaplist                    #list snapshots
iohyve roll bsdguest@beforeupdate  #rollback to snapshot

# Make an independent clone of a guest
# This is not a zfs clone, but a true copy of a dataset
iohyve clone bsdguest dolly	   #make a clone of bsdguest to dolly
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
