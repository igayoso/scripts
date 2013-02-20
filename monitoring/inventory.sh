echo "Resúmen de la máquina para el inventariado, algunos campos dependerán de la configuración hecha previamente..."
echo "IMPORTANTE: EJECUTARLO COMO root"

### HOSTNAME
HOSTNAME=`hostname -f`
echo "HOSTNAME=$HOSTNAME"

### OS
OS='debian'
DEBIAN_VERSION=`cat /etc/debian_version`
echo "OS=$OS-$DEBIAN_VERSION"

### CPU
NCPU='2'
CPUMODEL=`cat /proc/cpuinfo | grep "model name" | cut -f2 -d: | uniq`
echo "CPU=$NCPU x $CPUMODEL"

### MODEL & S/N
ILOHOSTNAME=`hostname -f | sed 's/srv/ilo/g'`
echo "INTRODUCE LA CONTRASEÑA PARA ENTRAR A LA ILO"
FAB_MODEL=`ssh Administrator@$ILOHOSTNAME 'show /system1' | egrep "    number|    name" | sed 's/    name=/FAB-MODEL=HP-/g' | sed 's/    number=/S\/N=/g'`
echo "$FAB_MODEL"

### HD
CON=0
echo "HDs"
for HD in `fdisk -l | egrep 'Disk.*bytes' | awk '{ sub(/,/,""); print $3" "$4 }'`
do
	echo "HD$CON=$HD"
	$CON=$[$CON + 1]
done

### RAM
RAMsizekb=`cat /proc/meminfo | grep MemTotal | tr -d ' ' | cut -d':' -f2 | tr -d 'kB'`
RAMsize=`expr $RAMsizekb / 1024`
echo "RAM=$RAMsize"

### NET
echo "NETWORK INTERFACES"
for i in `ifconfig | grep "eth[0-9]" | cut -f1 -d' ' | egrep -v ':|\.'`
do
	echo "$i=" `ifconfig $i | grep -w inet | cut -d":" -f2 | cut -d" " -f1`
done


