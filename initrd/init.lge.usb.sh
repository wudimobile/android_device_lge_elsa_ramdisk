#!/system/bin/sh
# Allow USB enumeration with default PID/VID
if [ -e /sys/class/android_usb/f_mass_storage/lun/nofua ];
then
    echo 1  > /sys/class/android_usb/f_mass_storage/lun/nofua
fi
if [ -e /sys/class/android_usb/f_mass_storage/rom/nofua ];
then
    echo 1  > /sys/class/android_usb/f_mass_storage/rom/nofua
fi

usb_config=`getprop persist.sys.usb.config`
case "$usb_config" in
    "" | "pc_suite" | "mtp_only" | "auto_conf")
        setprop persist.sys.usb.config mtp
        ;;
    "adb" | "pc_suite,adb" | "mtp_only,adb" | "auto_conf,adb")
        setprop persist.sys.usb.config mtp,adb
        ;;
    "ptp_only")
        setprop persist.sys.usb.config ptp
        ;;
    "ptp_only,adb")
        setprop persist.sys.usb.config ptp,adb
        ;;
    * ) ;; #USB persist config exists, do nothing
esac

# Set platform variables
if [ -f /sys/devices/soc0/hw_platform ]; then
    soc_hwplatform=`cat /sys/devices/soc0/hw_platform` 2> /dev/null
else
    soc_hwplatform=`cat /sys/devices/system/soc/soc0/hw_platform` 2> /dev/null
fi

echo BAM2BAM_IPA > /sys/class/android_usb/android0/f_rndis_qc/rndis_transports
echo qti,bam2bam_ipa > /sys/class/android_usb/android0/f_rmnet/transports