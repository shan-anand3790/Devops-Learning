#!/bin/bash

# server-stats.sh
# A script to collect and display basic server performance statistics.

# --- Styling and Variables ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

LOG_LINE="--------------------------------------------------------------------------------"

# --- Functions ---

# Function to display CPU Usage
get_cpu_usage() {
    echo -e "${BLUE}1. Total CPU Usage${NC}"
    echo $LOG_LINE

    # Get the idle percentage from the 'top' output
    # -b: Batch mode, -n1: 1 iteration
    # grep 'Cpu(s)' finds the CPU line
    # sed extracts the idle percentage (the value before '% id,')
    cpu_idle=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)% id.*/\1/")

    # Calculate used percentage (100 - idle)
    cpu_used=$(awk "BEGIN {printf \"%.1f\", 100.0 - $cpu_idle}")

    echo -e "CPU Used: ${RED}${cpu_used}%${NC} (Idle: ${GREEN}${cpu_idle}%${NC})"
    echo
}

# Function to display Memory Usage
get_memory_usage() {
    echo -e "${BLUE}2. Total Memory Usage (RAM)${NC}"
    echo $LOG_LINE

    # Use 'free -m' for output in megabytes
    mem_info=$(free -m | grep Mem)
    mem_total=$(echo $mem_info | awk '{print $2}')
    mem_used=$(echo $mem_info | awk '{print $3}')
    mem_free=$(echo $mem_info | awk '{print $4}')

    # Calculate percentage
    mem_percent=$(awk "BEGIN {printf \"%.1f\", ($mem_used/$mem_total) * 100}")

    echo -e "Total: ${CYAN}${mem_total}MB${NC}"
    echo -e "Used:  ${RED}${mem_used}MB${NC}"
    echo -e "Free:  ${GREEN}${mem_free}MB${NC}"
    echo -e "Used Percentage: ${YELLOW}${mem_percent}%${NC}"
    echo
}

# Function to display Disk Usage (Focusing on the root filesystem)
get_disk_usage() {
    echo -e "${BLUE}3. Total Disk Usage (Root Filesystem /)${NC}"
    echo $LOG_LINE

    # Use 'df -h /' to get human-readable stats for the root filesystem
    disk_info=$(df -h / | tail -1)
    disk_total=$(echo $disk_info | awk '{print $2}')
    disk_used=$(echo $disk_info | awk '{print $3}')
    disk_free=$(echo $disk_info | awk '{print $4}')
    disk_percent=$(echo $disk_info | awk '{print $5}')

    echo -e "Total Size: ${CYAN}${disk_total}${NC}"
    echo -e "Used Space: ${RED}${disk_used}${NC}"
    echo -e "Free Space: ${GREEN}${disk_free}${NC}"
    echo -e "Used Percentage: ${YELLOW}${disk_percent}${NC}"
    echo
}

# Function to display Top 5 CPU Processes
get_top_cpu_processes() {
    echo -e "${BLUE}4. Top 5 Processes by CPU Usage${NC}"
    echo $LOG_LINE
    # ps aux: lists all processes with detailed info
    # --sort=-%cpu: sorts by CPU usage in descending order
    # head -n 6: gets the header line + the top 5 results
    ps aux --sort=-%cpu | head -n 6
    echo
}

# Function to display Top 5 Memory Processes
get_top_mem_processes() {
    echo -e "${BLUE}5. Top 5 Processes by Memory Usage${NC}"
    echo $LOG_LINE
    # ps aux: lists all processes with detailed info
    # --sort=-%mem: sorts by Memory usage in descending order
    # head -n 6: gets the header line + the top 5 results
    ps aux --sort=-%mem | head -n 6
    echo
}

# --- Main Execution ---

clear
echo -e "${CYAN}=== SERVER PERFORMANCE SNAPSHOT: $(hostname) @ $(date) ===${NC}"
echo $LOG_LINE

get_cpu_usage
get_memory_usage
get_disk_usage
get_top_cpu_processes
get_top_mem_processes

echo -e "${CYAN}=== Report Complete ===${NC}"

# Exit with success status
exit 0
