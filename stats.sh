#!/bin/sh

# To collect 'stats' on an instance.
# Script by Mathias Meyer, http://github.com/mattmatt
 
time=`date +'%s'`
load_avg=`uptime | sed 's/^.\+load average: \(.\+\)/\1/' | sed 's/,//' | awk '{print $1}'`
 
memory=`free -o | grep Mem:`
mem_total=`echo $memory | awk '{print $2}'`
mem_used=`echo $memory | awk '{print $3}'`
mem_free=`echo $memory | awk '{print $4}'`
mem_cached=`echo $memory | awk '{print $7}'`
 
cpu=`mpstat 1 1 | grep Average`
cpu_user=`echo $cpu | awk '{print $3}'`
cpu_sys=`echo $cpu | awk '{print $5}'`
cpu_iowait=`echo $cpu | awk '{print $6}'`
cpu_idle=`echo $cpu | awk '{print $11}'`
running_processes=`ps ax | wc -l`
 
echo "time:$time;load_avg:$load_avg;cpu_user:$cpu_user;cpu_sys:$cpu_sys;cpu_iowait:$cpu_iowait;cpu_idle:$cpu_idle;mem_cached:$mem_cached;mem_free:$mem_free;mem_used:$mem_used;mem_total:$mem_total;procs:$running_processes"