#!/bin/bash

# Default values for interval and format
interval=5
format="text"

# Function to show CPU usage
get_cpu_usage() {
  cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
  echo "CPU Usage: $cpu_usage"
}

# Function to show memory usage
get_memory_usage() {
  memory=$(free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
  echo "$memory"
}

# Function to show disk usage
get_disk_usage() {
  echo "Disk Usage:"
  df -h | awk '$NF=="/"{printf "Disk: %d/%dGB (%s)\n", $3,$2,$5}'
}

# Function to show top 5 CPU-consuming processes
get_top_processes() {
  echo "Top 5 CPU-consuming processes:"
  ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
}

# Function to generate report
generate_report() {
  echo "System Report - $(date)"
  echo "----------------------------------------"
  get_cpu_usage
  get_memory_usage
  get_disk_usage
  get_top_processes
  echo "----------------------------------------"
}

# Function to trigger alerts based on thresholds
check_alerts() {
  cpu_threshold=80
  mem_threshold=75
  disk_threshold=90

  current_cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
  current_mem=$(free | awk 'FNR == 2 {printf "%.0f", $3/$2*100}')
  current_disk=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

  if (( $(echo "$current_cpu > $cpu_threshold" | bc -l) )); then
    echo "Warning: CPU usage is above $cpu_threshold%!"
  fi

  if (( $(echo "$current_mem > $mem_threshold" | bc -l) )); then
    echo "Warning: Memory usage is above $mem_threshold%!"
  fi

  if (( current_disk > disk_threshold )); then
    echo "Warning: Disk usage is above $disk_threshold%!"
  fi
}

# Function to write report to file
write_report() {
  if [[ "$format" == "text" ]]; then
    generate_report >> system_report.txt
  elif [[ "$format" == "json" ]]; then
    generate_report | jq -R -s '.' > system_report.json
  elif [[ "$format" == "csv" ]]; then
    echo "Time,CPU Usage,Memory Usage,Disk Usage" > system_report.csv
    echo "$(date),$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'),$(free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)", $3,$2,$3*100/$2 }'),$(df -h | awk '$NF=="/"{printf "%d/%dGB (%s)", $3,$2,$5}')" >> system_report.csv
  fi
}

# Function to parse arguments
parse_arguments() {
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --interval) interval="$2"; shift ;;
      --format) format="$2"; shift ;;
      *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
  done
}

# Validate the output format
validate_format() {
  if [[ "$format" != "text" && "$format" != "json" && "$format" != "csv" ]]; then
    echo "Invalid format specified. Allowed formats: text, json, csv"
    exit 1
  fi
}

# Main function
main() {
  parse_arguments "$@"
  validate_format

  while true; do
    generate_report
    check_alerts
    write_report
    echo "Sleeping for $interval seconds..."
    sleep "$interval"
  done
}

main "$@"
