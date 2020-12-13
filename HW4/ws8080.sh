#!/bin/sh

for i in 0 1 2; do
    ping -c 1 1.1.1.1 | grep from | awk -F'=' ' { print($4); }' | awk -F' ' ' {print("ws8080: " $1); }';
    sleep 1;
done
