## Installing HardenedBSD

- The actual installation is pretty simple. I just grabbed the latest ISO 
from the HardenedBSD website and popped it in. Because of the name 
bhyve, and my ~~obession~~ facination with Star Trek, I will be 
renaming this box to 
"[borgcube](http://en.memory-alpha.wikia.com/wiki/Borg_cube)." 

- I tend to grab not only the `lib32` stuff, I also grab the `src` stuff 
because I compile my own kernel, but I won't be going into that today. 
I suggest you look into doing this if you don't: 
[RTFHB](https://www.freebsd.org/doc/handbook/kernelconfig.html).

- Next you'll find the partitioning screen. Nothing fancy here either, 
except when I run production stuff, I usually choose to run a "root on 
zfs" setup, so I can do something like a software RAID, but instead 
using ZFS mirroring. Because the amount of disks I have at my ready are 
limited (I use just 4x 1.0TB HDDS), I just auto-partition the first 
disk with UFS and save the other three for the 
[zpool](https://www.freebsd.org/cgi/man.cgi?query=zpool&sektion=8) 
later on. You can also manually partition and make your operating system 
partition smaller, and add the remaining free space to the zpool later on as 
well. Yes, [ZFS](https://www.freebsd.org/cgi/man.cgi?zfs%288%29) is 
pretty awesome, I know. Just make sure you have enough RAM to make it 
happy. Since we are making virtualization system, I assume you have 
some RAM to spare. 

- The rest of the installation is pretty self-explanatory, setting a 
static IP, adding a user, etc... Because this server will never 
(theoretically) be exposed to the internet, I add the user to the wheel 
group so I can just switch to the root user after login to administer 
guest operating systems. (`su -`) Bhyve can only be used by root as it 
now stands, but the bhyve team is looking to change that in the future. 
After installation, I exit to a shell to install the tools I will need 
to begin post installation tasks. I do this via `pkg install nano 
tmux git`, although most of the actual programs used by iohyve are built 
into FreeBSD, or can easily be compiled from source via the ports. In 
my fresh install tool box I have:
	- `nano` I'm offically not leet enough for `vi` yet. 
	- `tmux` I use a terminal multiplexer for two reasons, one is 
to feel like a hacker, the other is to manage multiple terminal 
sessions when dealing with multiple guest operating systems and their 
consoles. More on that later. 
	- `git` Because iohyve is not in FreeBSD ports yet, you have to 
grab the latest version from github.


## Post-installation zpool setup. 

There are a few things I like to do before to fresh servers, and I'm 
sure you do that too. I like to change my motd and the sshd port. Some 
install `sudo` and edit the sudoers file. After you do what you need to 
do, get the zpool set up so iohyve has a place to store things. For me, 
I can find out what disks I have available to me by running `ls /dev | 
grep ada` but you may have different disk names if you have a different 
controller. 
````
root@borgcube:~ # ls /dev | grep ada
ada0
ada0s1
ada0s1a
ada0s1b
ada1
ada2
ada3
````
From my output, I can tell that the operating system is installed on 
`/dev/ada0` which leaves `/dev/ada1`, `/dev/ada2`, and `/dev/ada3` to 
use for my zpool. For redundancy, I will be utilizing raidz which acts 
much like RAID-5. 
````
root@borgcube:~ # zpool create borgpool raidz1 /dev/ada1 /dev/ada2 /dev/ada3
````


## iohyve installation and prep. 

- Before installing and setting up iohyve, we must prepare the host 
first. Begin by adding the following to your `/boot/loader.conf` file:
````
vmm_load="YES"
nmdm_load="YES"
````

- Then add the following to your `/etc/sysctl.conf` file:
````
net.link.tap.up_on_open=1
````

- Next we set up the networking in `/etc/rc.conf`. Be sure to find out 
the correct name for your primary ethernet adapter. I can tell mine is 
`em0` because when I run `ifconfig` I can see it has a connection. 
While I am in `/etc/rc.conf` I will also make sure `zfs_enable` is set 
so `iohyve` will be able to use ZFS. My file looks something like this:
````
hostname="borgcube"
ifconfig_em0="inet XXX.XXX.XXX.XXX netmask XXX.XXX.XXX.0"
defaultrouter="XXX.XXX.XXX.XXX"

cloned_interfaces="bridge0 tap0"
ifconfig_bridge0="addm em0 addm tap0"

zfs_enable="YES"
sshd_enable="YES"

# Set dumpdev to "AUTO" to enable crash dumps, "NO" to disable
dumpdev="AUTO"
````

- We can now begin to install `iohyve` and run `make install` to 
install the script into the `/usr/local/sbin` folder. 
````
root@borgcube:~ # git clone https://github.com/pr1ntf/iohyve.git
Cloning into 'iohyve'...
remote: Counting objects: 383, done.
remote: Total 383 (delta 0), reused 0 (delta 0), pack-reused 383
Receiving objects: 100% (383/383), 109.21 KiB | 0 bytes/s, done.
Resolving deltas: 100% (165/165), done.
Checking connectivity... done.
root@borgcube:~ # cd iohyve/
root@borgcube:~/iohyve # make install
mkdir -p /usr/local/sbin
install -m 0555 iohyve /usr/local/sbin/
install rc.d/* /usr/local/etc/rc.d/
````

- At this point, I would `reboot` the system before going any further 
and check to make sure everything worked.
	
- Check to be sure the kernel modules were loaded:

````
root@borgcube:~ # kldstat | grep vmm && kldstat | grep nmdm
 2    1 0xffffffff81c96000 3634e0   vmm.ko
 3    1 0xffffffff81ffa000 50b0     nmdm.ko
````

- Check the if the tap sysctl is set:

````
root@borgcube:~ # sysctl -a | grep net.link.tap.up_on_open
net.link.tap.up_on_open: 1
````

- Check the networking for the tap and bridge interfaces:

````
root@borgcube:~ # ifconfig -a | grep bridge0 && ifconfig -a | grep tap0
bridge0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
tap0: flags=8902<BROADCAST,PROMISC,SIMPLEX,MULTICAST> metric 0 mtu 1500
````

- If you would like to run guest operating systems other than 
FreeBSD, you will need `grub2-bhyve`. I install from ports after 
running `portsnap fetch && portsnap extract`:

````
root@borgcube:~ # find /usr/ports -name "grub2-bhyve"
/usr/ports/sysutils/grub2-bhyve
root@borgcube:~ # cd /usr/ports/sysutils/grub2-bhyve && make install clean

...
...
...

````

- Next finish setting up iohyve by telling it which zpool to use. If 
you want to list the zpools available, you can run `zpool list`.

````
root@borgcube:~ # zpool list
NAME       SIZE  ALLOC   FREE  EXPANDSZ   FRAG    CAP  DEDUP  HEALTH  
ALTROOT
borgpool  2.72T   138K  2.72T         -     0%     0%  1.00x  ONLINE  -
root@borgcube:~ # iohyve setup borgpool
Setting up iohyve...
````

- You can see that it installed by running `zfs list`. 

````
root@borgcube:~ # zfs list
NAME                  USED  AVAIL  REFER  MOUNTPOINT
borgpool              318K  1.75T  24.0K  /borgpool
borgpool/iohyve      48.0K  1.75T  24.0K  /iohyve
borgpool/iohyve/ISO  24.0K  1.75T  24.0K  /iohyve/ISO
````


## Install a FreeBSD guest. 

- Fetch the installation media:
````
root@borgcube:~ # iohyve fetch 
ftp://ftp.freebsd.org/.../FreeBSD-10.2-RELEASE-amd64-bootonly.iso
Fetching 
ftp://ftp.freebsd.org/.../FreeBSD-10.2-RELEASE-amd64-bootonly.iso...
/iohyve/ISO/FreeBSD-10.2-RELEASE-amd64-bootonl100% of  230 MB 6883 kBps 
00m34s
root@borgcube:~ #
````

- Now here is where `tmux` comes in. Because bhyve doesn't emulate 
video, the console output is connected via serial console, in the case 
with iohyve, it uses `cu` to set up `nmdm` consoles for each guest. 
There are other ways to set this up, like directing output directly to 
`tmux` panes or xterm itself. If you opted to install a GUI before all 
of this, such as [i3](https://i3wm.org) you don't even need a 
multiplexer like `tmux`, you can just open a new terminal window. You 
can theoretically install a guest via one SSH session as well, using 
`<RETURN> ``.` to stop the nmdm connection and bring you back to your 
SSH prompt. This can get tricky and cause headaches, though.

- Create a guest named `freebsdguest` that has a disk size of 8 
gigabytes, then run the installation:
````
root@borgcube:~ # iohyve create freebsdguest 8G
Creating freebsdguest...
root@borgcube:~ # iohyve isolist
Listing ISO's...
FreeBSD-10.2-RELEASE-amd64-bootonly.iso
root@borgcube:~ # iohyve install freebsdguest FreeBSD-10.2-RELEASE-amd64-bootonly.iso
Installing freebsdguest...
````

- If you haven't already done so, open a new terminal (`Ctrl+b + c` on 
tmux) and run `iohyve console freebsdguest`. You may have to press 
enter once in the console. 

- As long as you choose to do a UFS install, you should be able to 
install just as usual. You can do a "root on zfs" install, but you have 
to up the amount of RAM the guest uses, as mentioned before, ZFS likes 
to nomnomnom on some RAM. The default amount of RAM iohyve set is 256M, 
but you can change that after guest creation, more on that later. 

- Once the installation is over, you can choose to "reboot" via the 
menu, but that actually won't reboot the guest, more on that another 
time. If you choose the "reboot" option on the menu, you must run 
`iohyve destroy freebsdguest` before going further. Otherwise, you can 
just go back to your orginal terminal and run 'iohyve stop 
freebsdguest' when it asks you to reboot and iohyve will gracefully 
stop the guest for clean startup on it's next start. 

- Now you can run `iohyve start freebsdguest` and switch back to the 
`iohyve console freebsdguest` terminal watch in glory as the guest 
operating system boots.  


## Other cool stuff you can do with iohyve

- Check all of the properties for a given guest:

````
root@borgcube:~ # iohyve getall freebsdguest
Getting freebsdguest props...
ram     256M
cpu     1
size    8G
loader  bhyveload
install no
boot    0
tap     tap0
name    freebsdguest
con     nmdm0
persist 1
````

- Increase RAM amount:

````
root@borgcube:~ # iohyve set freebsdguest ram=1024M
Setting freebsdguest prop ram=1024M...
root@borgcube:~ # iohyve get freebsdguest ram
Getting freebsdguest prop ram...
1024M
````

- Delete a guest:

````
root@borgcube:~ # iohyve list
Listing guests...
freebsdguest
naughtyguest
root@borgcube:~ # iohyve delete naughtyguest
Are you sure you want to delete naughtyguest [Y/N]? y
````

- List all running guests:

````
root@borgcube:~ # iohyve running
Listing running guests...
freebsdguest
````

- Start a guest at host boot time. Make sure `iohyve_enable="YES"` is 
set in your `/etc/rc.conf` file. 

````
root@borgcube:~ # iohyve set freebsdguest boot=1
Setting freebsdguest prop boot=1...
````


## Run a [Debian](https://debian.org) Linux guest.

- After fetching the ISO, create the guest as usual. I also like to 
give the guest a bit more RAM, too. 

````
root@borgcube:~ # iohyve create debianguest 8G
Creating debianguest...
root@borgcube:~ # iohyve set debianguest ram=512MB
Setting debianguest prop ram=512MB...
```` 

- Change the guest's bootloader by setting it in iohyve. Make sure you 
have installed grub2-bhyve as mentioned above. 
````
root@borgcube:~ # iohyve set debianguest loader=grub-bhyve
Setting debianguest prop loader=grub-bhyve...
````

- Install the guest as usual:
````
root@borgcube:~ # iohyve install debianguest 
debian-8.2.0-amd64-i386-netinst.iso
Installing debianguest...
````
