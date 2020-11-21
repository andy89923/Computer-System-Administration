#!/bin/sh

sed -e 1,9d |
awk -F" " ' BEGIN {
        nR=9999;
    }
    {
        tmp=$11;
        sub (/%/, "", tmp);
        printf "2 %s %s %s %s %s\n", tmp, $1, $12, $2, $11;
        printf "1 %d %s %s %s %s\n",  nR, $1, $12, $2, $7;
        --nR;
    }' |
sort -nrk 1,2 | 
awk -F' ' ' BEGIN { 
        cnt1=0; 
        cnt2=0;
        print "Top Five Processes of WCPU over 0.5\n";
        print "PID   command      user      WCPU";
    }
    $1 == 2 && $2 >= 0.50 && cnt2 < 5 {
        ++cnt2;
        printf "%-5s %-12s %-8s %-4s\n", $3, $4, $5, $6;
        arry[$5] += 1;
    }
    $1 == 1 && cnt1 < 5 {
        if (cnt1 == 0) {
            print "\nTop Five Processes of RES\n";
            print "PID   command      user      RES";
        }
        ++cnt1;
        printf "%-5s %-12s %-8s %-4s\n", $3, $4, $5, $6;
	arry[$5] += 1;
    }
    END {
    	print "\nBad Users:\n";
    	for (var in arry) { 
	    if(var == "root") print "\033[32m"var"\033[0m";
	    else if (arry[var] == 1) print "\033[33m"var"\033[0m";
	    else 
		print "\033[31m"var"\033[m";
    	}
	tput sgr0;
    }'
