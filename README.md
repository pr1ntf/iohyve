# iocage
FreeBSD bhyve manager utilizing ZFS.

So far FreeBSD guests work with relativly no hassle. Linux guests can be a bit more tricky, but with a little help you can make them persist. 

Just read the man page 'iohyve man' built in for help. 

# Pre-FLight Checklist
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

