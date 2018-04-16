#Tested on Dell R730 server with iDRAC, this script is run under a linux server with racadm installed
hosts=$@

if [ -z "$hosts" ] ; then
  echo "Please fill in servers' iDRAC IP"
else
	echo "#################################set bootmode#########################################"
	for host in $hosts
	do
	        #racadm -r $host -u root -p calvin set BIOS.BiosBootSettings.BootMode Uefi
	        racadm -r $host -u root -p calvin set BIOS.BiosBootSettings.BootMode BIOS
	        racadm -r $host -u root -p calvin jobqueue create BIOS.Setup.1-1
	        racadm -r $host -u root -p calvin serveraction hardreset
	        sleep 600
	done

	echo "#################################Create new vdisks#########################################"
	for host in $hosts
	do
	        racadm -r $host -u root -p calvin raid createvd:RAID.Integrated.1-1 -rl r1 -pdkey:Disk.Bay.0:Enclosure.Internal.0-1:RAID.Integrated.1-1,Disk.Bay.1:Enclosure.Internal.0-1:RAID.Integrated.1-1
	        racadm -r $host -u root -p calvin raid createvd:RAID.Integrated.1-1 -rl r5 -pdkey:Disk.Bay.2:Enclosure.Internal.0-1:RAID.Integrated.1-1,Disk.Bay.3:Enclosure.Internal.0-1:RAID.Integrated.1-1,Disk.Bay.4:Enclosure.Internal.0-1:RAID.Integrated.1-1,Disk.Bay.5:Enclosure.Internal.0-1:RAID.Integrated.1-1,Disk.Bay.6:Enclosure.Internal.0-1:RAID.Integrated.1-1
		sleep 120
		racadm -r $host -u root -p calvin jobqueue create RAID.Integrated.1-1 -s TIME_NOW --realtime
	done

	echo "#################################Setting NIC LegacyBootProto#########################################"
	for host in $hosts
	do
	        racadm -r $host -u root -p calvin set NIC.NICConfig.1.LegacyBootProto NONE
	        racadm -r $host -u root -p calvin set NIC.NICConfig.3.LegacyBootProto PXE
	        racadm -r $host -u root -p calvin jobqueue create NIC.Integrated.1-1-1 -r pwrcycle -s `date +%Y%m%d%H%M%S -d '2 min'`
	        racadm -r $host -u root -p calvin jobqueue create NIC.Integrated.1-3-1 -r pwrcycle -s `date +%Y%m%d%H%M%S -d '2 min'`
	        racadm -r $host -u root -p calvin config -g cfgServerInfo -o cfgServerBootOnce 1
	        racadm -r $host -u root -p calvin config -g cfgServerInfo -o cfgServerFirstBootDevice PXE
	done
fi
