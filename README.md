# iohyve
FreeBSD bhyve manager utilizing ZFS
NAME
  iohyve(8) - bhyve manager/launcher v0.2 "I made a thing"
  
SYNOPSIS
  iohyve version
  iohyve setup [pool]
  iohyve list
  iohyve isolist
  iohyve vmmlist
  iohyve running
  iohyve fetch [URL] 
  iohyve remove [ISO]
  iohyve create [name] [size] [console]
  iohyve install [name] [ISO] 
  iohyve load [name]
  iohyve boot [name] [ISO]
  iohyve start [name]
  iohyve stop [name]
  iohyve off [name]
  iohyve scram
  iohyve destroy [name]
  iohyve delete [name]
  iohyve set [name] [prop=value]
  iohyve get [name] [prop]
  iohyve getall [name]
  iohyve conlist
  iohyve console [name]
  iohyve readme
  iohyve help
  iohyve man
  
DESCRIPTION
  The iohyve(8) shell script utilizes the FreeBSD hypervisor bhyve(8), 
  zfs(8), and nmdm(4) to make virtualization on FreeBSD easy and simple.
  Currently, only FreeBSD guests can be configured, with more on the way.
  The basic idea is to store bhyve settings in zfs user properties of zfs 
  datasets that house important guest files like block devices and grub 
  configurations. iohyve(8) uses the virtio drivers built into the GENERIC 
  kernel for virtualization. iohyve(8) does not run out of the box. For
  starters, you will need to run 'kldload vmm' for bhyve and 'kldload nmdm' 
  for the null modem device that helps you connect with  your virtual guest. 
  You can run 'iohyve readme' to learn more about host configuration. 
  
  You have been warned, iohyve(8) is very beta. Some things do not look
  pretty or sometimes just do not work. Better looking lists and 
  support for other BSDs and Linux are coming soon with v0.3
  Utilization of UUIDs and prepending of ioh- to pids will help. 

OPTIONS
  version   Prints the current running version of iohyve
  
  setup     Installs required zfs datasets for iohyve to function.
              
            Usage: 'iohyve setup [poolname]' where [poolname] is the zpool
                    you want to install iohyve on.
              
  list      Lists the zfs dataset directorys for iohyve. 
  
  isolist   Lists the installed ISOs in the /iohyve/ISO directory.
  
  vmmlist   Lists the current guests that are loaded into bhyves VMM. 
            (Use to see who has resources)
  
  running   Lists all the current running and booted guests by Process ID.
  
  fetch     Fetches installation ISO or install image and creates a
            dataset for it. 
             
            Usage: 'iohyve fetch [URL]' where [URL] is the HTTP or FTP URL to 
                    fetch from the internet. 
              
  remove    Removes installed ISO from /iohyve/ISO
  
            Usage: 'iohyve remove [ISO]' where [ISO] is the name of the ISO 
                    you would like to delete.
  
  create    Creates new guest operating system.
              
            Usage: 'iohyve create [name] [size] [console]' where [name] is
                    the name you would like to use, [size] is the size of the
                    virtual block device in '16G' format where the capital G 
                    signifies gigabytes, and [console] is the name of the null 
                    modem device in the form of 'nmdmN' where N is 0-99 leaving 
                    out the /dev/ & A or B.
                    (See console options below for more details)
                    
  install   Loads and boots into ISO for guest installation. 
            
            Usage: 'iohyve install [name] [ISO]' where [name] is the name
                    of the guest, and [ISO] is the name of the ISO you would
                    like to boot from in the form of: 'instal.iso'
                    
  load      Loads the guest operating system bootloader and resources.
  
            Usage: 'iohyve load [name]' where [name] is the name
                    of the guest operating system.
  
  boot      Boots the guest into the operating system. 'iohyve run' needs
            to be run before this is done. 
            
            Usage: 'iohyve boot [name] [ISO]' where [name] is the name
                    of the guest operating system.  [ISO] is optional and
                    only for non FreeBSD guests.
  
  start     Starts the guest operating system. (Combines load & boot)
  
            Usage: 'iohyve start [name]' where [name] is the name
                    of the guest operating system.
  
  stop      Gracefully stops guest operating system.
  
            Usage: 'iohyve stop [name]' where [name] is the name
                    of the guest operating system.
  
  off       Forces a power off of guest. Also destroys guest resources.
  
            Usage: 'iohyve off [name]' where [name] is the name
                    of the guest operating system.
                    
  scram     Gracefully stop all bhyve guests. Does not destroy resources.
  
  destroy   Destroys guest resources. 
            (Resources viewed with 'iocage vmmlist')
            
            Usage: 'iohyve destroy [name]' where [name] is the name
                    of the guest operating system.
                    
  delete    Deletes all data for the guest.
            
            Usage: 'iohyve delete [name]' where [name] is the name
                    of the guest operating system.
                    
  set       Sets ZFS properties for guests one at a time
  
            Usage: 'iohyve set [name] [prop=value]' where [name] is the name
                    of the guest operating system.
            Properties: 
                    ram=512M or ram=2G (M for megabytes, G for gigabtyes)
                    cpu=1 (number of cpu cores)
                    con=nmdm0 (where to attach null modem console)
                    tap=tap0 (tap device for virtio-net)
                    size=size of block device
                    name=name of guest
                    os=the OS type (freebsd, debian, centos, etc...)
                    loader=the boot loader (bhyveload or grub)
  
  get       Gets ZFS properties for guests one at a time
            
            Usage: 'iohyve get [name] [prop]' where [name] is the name
                    of the guest operating system. [prop] is the 
                    property you want to view. (See 'iohyve set' info)
  
  getall    Gets all the ZFS properties for a guest
            
            Usage: 'iohyve getall [name]' where [name] is the name
                    of the guest operating system.
                    
  conlist   Lists all of the connected and in use nullmodem consoles
  
  console   Consoles into a guest operating system. Utilizes nmdm(4) and
            cu(1) to open a console on a guest operating system. Since
            bhyve(8) does not emulate video, so we need to administer 
            the guests via a serial communication device. Since iohyve
            uses cu(1), you will need to press the tilde (~) twice
            then period (.) to exit the console. 
            (Think typing ~~. real fast to exit console)
  
            Usage: 'iohyve console [name]' where [name] is the name
                    of the guest operating system.
  
  readme    Outputs README file. You can run 'iohyve readme > README.txt' 
            to save the readme to a file.
  
  help      General usage help.
  
  man       This man page. 

EXAMPLES


AUTHOR
  Trent -- @pr1ntf

THANKS
  @pannon
  @skarekrow

SEE ALSO
  bhyve(8), bhyveload(4), zfs(8), nmdm(4), cu(1)
  
# Quick Pre-flight checklist ###

iohyve's network is meant to work either via VNET or Shared IP, both utilizing tap(4)
The goal is to potentialy have bhyve guests and iocage jails living on the same VNET
Things labeled as NEEDED are needed at the very least for shared IP guests. 
Everything else is for VNET.


The following needs to be added to kernal config and recompiled
options     VIMAGE    # VNET/VIMAGE option for VNET only. 

VirtIO support (Included in GENERIC kernel)
device          virtio                  # Generic VirtIO bus (required)
device          virtio_pci              # VirtIO PCI device
device          vtnet                   # VirtIO Ethernet device
device          virtio_blk              # VirtIO Block device
device          virtio_scsi             # VirtIO SCSI device
device          virtio_balloon          # VirtIO Memory Balloon device


Below is added to /boot/loader.conf
vmm_load="YES"        # bhyve module NEEDED
nmdm_load="YES"       # For the nullmodem console NEEDED
if_bridge_load="YES"  # bridge module NEEDED
if_tap_load="YES"     # tap module NEEDED


These are added to /etc/sysctl.conf
net.link.tap.up_on_open=1     # tap setup NEEDED
net.inet.ip.forwarding=1      # gateway setup
net.link.bridge.pfil_onlyip=0 # misc gotcha
net.link.bridge.pfil_bridge=0 # misc gotcha
net.link.bridge.pfil_member=0 # misc gotca


Below is added to /etc/rc.conf for firewall and VNET stuff
cloned_interfaces="bridge0 bridge1 tap0"                # bridge1 not needed for non-vnet setups
ifconfig_bridge0="addm em0 10.10.123.1/24 up addm tap0" # 10.10.155.1 is the VNET Gateway
                                                         # '10.10.123.1/24 up' not needed for non-vnet
gateway_enable="YES"                                    # Not needed for non-vnet setups
pf_enable="YES"                                         # Not needed for non-vnet setups
pf_rules="/etc/pf.conf"                                 # Not needed for non-vnet setups
pflog_enable="yes"                                      # Not needed for non-vnet setups


Below is an example /etc/pf.conf ***Not needed for non-vnet setups
Remember to start pf service and run 'pfctl -ef /etc/pf.conf'

pub="XXX.XXX.XXX.XXX"           # IP address of host
jail_net="10.10.155.00/24"      #
example_jail="10.10.155.10"     # Already existing iocage vnet jail
example_guest="10.10.155.11"    # IP for new guest
if="em0"                        # The physical ethernet interface
 
set block-policy return
set skip on lo
scrub in
 
#NAT
nat on $if from $example_jail to !$jail_net -> $pub   # Give jail route out
nat on $if from $example_guest to !$jail_net -> $pub  # Give guest route out
 
default
pass out on $if from $pub to any
block in log on $if
 
ssh on the host machine
pass in quick on $if proto tcp from any to $pub port 4444   # my SSH port is on 4444
