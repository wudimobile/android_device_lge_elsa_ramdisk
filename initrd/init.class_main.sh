#!/system/bin/sh

# start ril-daemon only for targets on which radio is present
    start ipacm-diag
    start ipacm
    start qti
    start netmgrd

# Allow persistent faking of bms
# User needs to set fake bms charge in persist.bms.fake_batt_capacity
fake_batt_capacity=`getprop persist.bms.fake_batt_capacity`
case "$fake_batt_capacity" in
    "") ;; #Do nothing here
    * )
    echo "$fake_batt_capacity" > /sys/class/power_supply/battery/capacity
    ;;
esac
