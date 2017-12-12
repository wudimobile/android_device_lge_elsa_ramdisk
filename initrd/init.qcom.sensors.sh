#!/system/bin/sh

# Function to start sensors for SSC enabled platforms
start_sensors()
{
    if [ -c /dev/msm_dsps -o -c /dev/sensors ]; then
        chmod -h 0775 /persist/sensors
        chmod -h 0664 /persist/sensors/sensors_settings
        chown -h system.root /persist/sensors/sensors_settings

        mkdir -p /data/misc/sensors
        chmod -h 0775 /data/misc/sensors

        start sensors
    fi
}

start_sensors
