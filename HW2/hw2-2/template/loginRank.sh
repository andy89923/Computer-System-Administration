mons=`date +%b`;
last | grep $mons | awk -F' ' '{print $1;}' | sed '$d' | sort |
	awk -F' ' 'BEGIN {}
		{ arry[$1] += 1 }
		END {
		    for (var in arry) { 
    		   	print arry[var], var;	
		    }
		}' |
	sort -nrk 1 | 
	awk -F' ' ' BEGIN { 
			cnt = 0;
			printf "Rank Name        Times\n"
		    }
		    cnt < 5 {
		    	cnt += 1;
	    		printf "%-5s %-11s %-3s\n", cnt, $2, $1;
	    	    }'
				
