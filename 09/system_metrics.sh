#!/bin/bash

OUTPUT_FILE="/var/www/html/metrics.html"

generate_metrics() {
    # CPU load percentage
    CPU_LOAD=$(awk '/cpu /{usage=($2+$4)*100/($2+$4+$5)} END {print usage}' /proc/stat)

    # Memory metrics (convert to bytes)
    MEMORY_TOTAL=$(awk '/MemTotal/ {print $2 * 1024}' /proc/meminfo)
    MEMORY_FREE=$(awk '/MemFree/ {print $2 * 1024}' /proc/meminfo)

    # Disk usage percentage for root filesystem
    DISK_USAGE=$(df / | awk '/\/$/ {print $5}' | tr -d '%')

    # Write metrics in Prometheus format
    cat <<EOF > $OUTPUT_FILE
# HELP cpu_load Current CPU load percentage
# TYPE cpu_load gauge
cpu_load $CPU_LOAD
# HELP memory_total Total memory in bytes
# TYPE memory_total gauge
memory_total $MEMORY_TOTAL
# HELP memory_free Free memory in bytes
# TYPE memory_free gauge
memory_free $MEMORY_FREE
# HELP disk_usage Disk usage percentage
# TYPE disk_usage gauge
disk_usage $DISK_USAGE
EOF
}

while true; do
    generate_metrics
    sleep 3
done
