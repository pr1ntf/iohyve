# iocage
FreeBSD bhyve manager utilizing ZFS.

So far FreeBSD guests work with relativly no hassle. Linux guests can be a bit more tricky, but with a little help you can make them persist. 

Just read the man page 'iohyve man' built in for help. 

# Pre-Flight Checklist
[Taken from the FreeBSD handbook https://www.freebsd.org/doc/en/books/handbook/virtualization-host-bhyve.html]
The first step to creating a virtual machine in bhyve is configuring the host system. First, load the bhyve kernel module:

    kldload vmm

Then, create a tap interface for the network device in the virtual machine to attach to. In order for the network device to participate in the network, also create a bridge interface containing the tap 
interface ane the physical interface as members. In this example, the physical interface is igb0:

    ifconfig tap0 create
    sysctl net.link.tap.up_on_open=1
        net.link.tap.up_on_open: 0 -> 1
    ifconfig bridge0 create
    ifconfig bridge0 addm igb0 addm tap0
    ifconfig bridge0 up

The built-in readme 'iohyve readme' has more information on VNET setups. 

# Usage

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

# Setup
Setup iohyve by telling it what zpool to use

    iohyve setup tank

# FreeBSD Guests
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
