
LANG=en_US.utf8;date;hostname; dmidecode -s system-serial-number;hostnamectl;ls -l /root/anaconda-ks.cfg;ip a|grep "inet "|grep " brd ";fdisk -l /dev/sda /dev/vda|egrep "Disk ";lsmem|grep 'Total online';lscpu|egrep -i 'Archi|CPU\(s\):|Thread|core|Socket'|grep -v NUMA;cat /etc/system-release
