#!/system/bin/sh

soc_info=`cat /sys/devices/soc0/machine`

setprop ro.soc_info $soc_info
