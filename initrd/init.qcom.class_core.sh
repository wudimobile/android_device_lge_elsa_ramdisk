#!/system/bin/sh
# Set platform variables
target=`getprop ro.board.platform`
if [ -f /sys/devices/soc0/hw_platform ]; then
    soc_hwplatform=`cat /sys/devices/soc0/hw_platform` 2> /dev/null
else
    soc_hwplatform=`cat /sys/devices/system/soc/soc0/hw_platform` 2> /dev/null
fi
if [ -f /sys/devices/soc0/soc_id ]; then
    soc_hwid=`cat /sys/devices/soc0/soc_id` 2> /dev/null
else
    soc_hwid=`cat /sys/devices/system/soc/soc0/id` 2> /dev/null
fi
if [ -f /sys/devices/soc0/platform_version ]; then
    soc_hwver=`cat /sys/devices/soc0/platform_version` 2> /dev/null
else
    soc_hwver=`cat /sys/devices/system/soc/soc0/platform_version` 2> /dev/null
fi


# Dynamic Memory Managment (DMM) provides a sys file system to the userspace
# that can be used to plug in/out memory that has been configured as unstable.
# This unstable memory can be in Active or In-Active State.
# Each of which the userspace can request by writing to a sys file.
#
# ro.dev.dmm = 1; Indicates that DMM is enabled in the Android User Space. This
# property is set in the Android system properties file.
#
# If ro.dev.dmm.dpd.start_address is set here then the target has a memory
# configuration that supports DynamicMemoryManagement.
init_DMM()
{
    block=-1

    case "$target" in
    *)
        return
        ;;
    esac

    mem="/sys/devices/system/memory"
    op=`cat $mem/movable_start_bytes`
    case "$op" in
    "0")
        log -p i -t DMM DMM Disabled. movable_start_bytes not set: $op
        ;;

    "$mem/movable_start_bytes: No such file or directory ")
        log -p i -t DMM DMM Disabled. movable_start_bytes does not exist: $op
        ;;

    *)
        log -p i -t DMM DMM available. movable_start_bytes at $op
        movable_start_bytes=0x`cat $mem/movable_start_bytes`
        block_size_bytes=0x`cat $mem/block_size_bytes`
        block=$((#${movable_start_bytes}/${block_size_bytes}))

        chown -h system.system $mem/memory$block/state
        chown -h system.system $mem/probe
        chown -h system.system $mem/active
        chown -h system.system $mem/remove

        setprop ro.dev.dmm.dpd.start_address $movable_start_bytes
        setprop ro.dev.dmm.dpd.block $block
        ;;
    esac

    # For 7X30 targets:
    # ro.dev.dmm.dpd.start_address is set when the target has a 2x256Mb memory
    # configuration. This is also used to indicate that the target is capable of
    # setting EBI-1 to Deep Power Down or Self Refresh.
    op=`cat $mem/low_power_memory_start_bytes`
    case "$op" in
    "0")
        log -p i -t DMM Self-Refresh-Only Disabled. low_power_memory_start_bytes not set:$op
        ;;
    "$mem/low_power_memory_start_bytes No such file or directory ")
        log -p i -t DMM Self-Refresh-Only Disabled. low_power_memory_start_bytes does not exist:$op
        ;;
    *)
        log -p i -t DMM Self-Refresh-Only available. low_power_memory_start_bytes at $op
        ;;
    esac
}

#
# For controlling console and shell on console on 8960 - perist.serial.enable 8960
# On other target use default ro.debuggable property.
#
serial=`getprop persist.serial.enable`
dserial=`getprop ro.debuggable`
case "$target" in
    *)
        case "$dserial" in
            "1")
                start console
                ;;
        esac
        ;;
esac
