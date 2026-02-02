#!/bin/bash

unset ALL_VMS_FILE
ALL_VMS_FILE=$HOME/inventory/all-vms-report

### ===== Getting all virtual machines from kvm hypervisors =====

KVM_HOSTS="
alheli
onagra
redommod
redomtor
redomyec
cica
coco
mmptest1
mmpyec1
mmptor1
"

#echo '"KVM_MANAGER","KVM_HOST","NAME","STATUS"'

for ip in $( echo $KVM_HOSTS )
do
        for line in $( ssh -q $ip "( export LC_ALL=en_US.utf8; sudo virsh list --all ) 2>/dev/null" | egrep -vi 'id *name *state|---|^$' | awk '{print $2","$3}' )
	do
                echo ",$ip,$line"
	done
done > $ALL_VMS_FILE

### ===== Getting all virtual machines from oVirt hypervisors =====

OVIRT_HOSTS="
rhv-mgr-yec,rhvyec01
rhv-mgr-yec,rhvyec02
rhv-mgr-yec,rhvyec03
rhv-mgr-yec,rhvyec04
rhv-mgr-yec,thalia
rhv-mgr-tor,peral
rhv-mgr-tor,yunco
rhv-mgr-tor,rhvtor01
rhv-mgr-tor,rhvtor02
rhv-mgr-tor,rhvtor03
rhv-mgr-ms,rhvmstor1
rhv-mgr-ms,rhvmsyec1
rhv-mgr-pci,lynxofftor
rhv-mgr-pci,lynxoffyec
ora-mgr-mmp,mmpyec2
ora-mgr-mmp,mmptor2
ora-mgr-mmp,mmptest2
"

#echo '"ENGINE","HYPERVISOR","NAME","GUEST","FQDN","STATUS"'

for line in $( echo $OVIRT_HOSTS )
do
        ip=$( echo $line | cut -d',' -f2 )
        ssh -q $ip "sudo vdsm-client Host getAllVmStats" | jq -r ' .[] | [.vmName,.guestName,.guestFQDN,.status] | @csv ' | sed "s/^/\"$line\",/" | tr -d '"'
done >> $ALL_VMS_FILE

### ===== Getting all virtual machines from VCenters =====

scp $HOME/bin/remote/my-get-vcenters kyngest1: &>/dev/null && ssh kyngest1 "bash my-get-vcenters" >> $ALL_VMS_FILE

