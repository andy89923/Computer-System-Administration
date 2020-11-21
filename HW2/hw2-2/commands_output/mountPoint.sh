# !/bin/sh

df -HT -t zfs,nfs | sed 1d | 
	awk -F' ' '{
		    printf "%-30s %-30s\n", $1, $7;
		}'
