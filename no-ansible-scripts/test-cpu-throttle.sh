i#!/usr/bin/env bash

set -u

DURATION="${1:-120}"
HOSTNAME="$(hostname -s)"

# Contador de throttling térmico antes de la prueba
before=0
for f in /sys/devices/system/cpu/cpu*/thermal_throttle/core_throttle_count; do
    [[ -r "$f" ]] && before=$((before + $(cat "$f")))
done

# Temperatura máxima observada
max_temp=0

# Monitor térmico en segundo plano
while true; do
    for f in /sys/class/thermal/thermal_zone*/temp; do
        [[ -r "$f" ]] || continue
        temp=$(awk '{printf "%.1f", $1/1000}' "$f")
        awk "BEGIN {exit !($temp > $max_temp)}" && max_temp="$temp"
    done
    sleep 1
done &
monitor_pid=$!

trap 'kill "$monitor_pid" 2>/dev/null; exit 1' INT TERM

echo "[$HOSTNAME] CPU stress: ${DURATION}s"

# Carga intensa de CPU en todos los cores
stress-ng \
    --cpu 0 \
    --cpu-method matrixprod \
    --cpu-load 100 \
    --timeout "${DURATION}s" \
    --quiet

kill "$monitor_pid" 2>/dev/null
wait "$monitor_pid" 2>/dev/null

# Contador después de la prueba
after=0
for f in /sys/devices/system/cpu/cpu*/thermal_throttle/core_throttle_count; do
    [[ -r "$f" ]] && after=$((after + $(cat "$f")))
done

throttle=$((after - before))

if (( throttle > 0 )); then
    status="THROTTLE"
else
    status="OK"
fi

printf '%-15s %-10s throttle=%-6s max_temp=%s°C\n' \
    "$HOSTNAME" "$status" "$throttle" "$max_temp"
