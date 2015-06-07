# iohyve v0.3
"Nix the other nix edition"
FreeBSD bhyve manager utilizing ZFS and other FreeBSD tools. 

iohyve creates, stores, manages, and launches bhyve guests utilizing built in FreeBSD features including virtio drivers and ZFS. 
iohyve strives to be much like @pannon's iocage (Jail Manager), storing properties in ZFS datasets. 
[https://github.com/iocage/iocage]
There is currently support for VIMAGE/VNET just as iocage. Documentation soon to come. For more information on VNET support, run:

    iohyve readme

Or create a readme file:

    iohyve readme > awesomesauce.txt 

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
        conreset
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

Once installation is done, exit console (~~.) and stop guest:

    iohyve stop bsdguest

Now that the guest is installed, it can be started like usual:

    iohyve start bsdguest

Some guest os's can be gracefully stopped:

    iohyve stop bsdguest

**Persistence**

FreeBSD guests can now persist after the guest reboots or shutdowns. This means if you reboot the guest from console, it 
will come back up without having to start manually. There is an issue with grub 
where it will not auto boot. You must connect via console to initiate boot. As of version 2.12, guests still don't 
persist after host reboot. 

This is done by simply appending '-p &' to the end of the start command:

    iohyve start bsdguest -p &

Stop a persistent guest:

    iohyve stop bsdguest

Destroy a hung persistent guest:

    iohyve destroy bsdguest

Turn off persistence flag so guest will shut down instead of reboot:

    iohyve set bsdguest persist=0

