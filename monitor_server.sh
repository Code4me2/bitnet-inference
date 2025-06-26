#!/bin/bash

# BitNet Server Monitoring Script
# Monitors server health, slots, and resource usage

SERVER_URL="http://localhost:8081"
LOG_FILE="monitoring.log"

echo "=== BitNet Server Monitor - $(date) ===" | tee -a $LOG_FILE

# Check server health
echo "Health Check:" | tee -a $LOG_FILE
curl -s $SERVER_URL/health | tee -a $LOG_FILE

# Check slots status
echo -e "\nSlots Status:" | tee -a $LOG_FILE
curl -s $SERVER_URL/slots | grep -o '"state":[0-9]*\|"id_task":[0-9-]*\|"n_ctx":[0-9]*\|"n_decoded":[0-9]*' | tee -a $LOG_FILE

# Check server process
echo -e "\nServer Process:" | tee -a $LOG_FILE
ps aux | grep llama-server | grep -v grep | awk '{print "CPU: " $3 "%, MEM: " $4 "%, RSS: " $6 "KB"}' | tee -a $LOG_FILE

# Check system load
echo -e "\nSystem Load:" | tee -a $LOG_FILE
cat /proc/loadavg | awk '{print "Load Average: " $1 " " $2 " " $3}' | tee -a $LOG_FILE

# Check memory
echo -e "\nMemory Usage:" | tee -a $LOG_FILE
free -h | grep "Mem:" | awk '{print "Used: " $3 "/" $2 " (" $3/$2*100 "%)"}' | tee -a $LOG_FILE

echo "========================================" | tee -a $LOG_FILE