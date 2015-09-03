#!/bin/sh

### When Upgrading from v0.5.5 to v0.5.6 you must run this script
### It renames the zvol disk images to the finalized disk naming scheme

### This script will shut down all of your guests before running
### You should reboot after running. I know this is suboptimal

echo 'Stopping all guests (scram)'
./iohyve scram

pool="$(zfs list | grep iohyve | head -n1 | cut -d '/' -f 1)"
guestlist="$(zfs list | grep iohyve | grep -v ISO | grep -v .img | \
	cut -d ' ' -f 1 | cut -d '/' -f 3 | sed 1d)"

for i in $guestlist ; do
	zfs rename $pool/iohyve/$i/$i-0.img \
		$pool/iohyve/$i/disk0
done

echo 'Done.'
