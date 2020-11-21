# !/bin/sh

echo "This System Report is generated on" `date`
echo "================================================================="

uname -a | awk -F' ' '{
	print "Hostname:", $2;
	print "OS Name:", $1;
	print "OS Realease Version:", $3;
	print "OS Architecture:", $7;
}'

# echo "Hostname:" `hostname`
# echo "OS name:" `uname`
# echo "OS Release Version:" `uname -U`

sysctl hw.model hw.machine hw.ncpu | 
	awk -F' ' 'BEGIN{}
	$1 == "hw.model:" {
	    $1="";
	    print "Processor Model:", $0;
	}
	$1 == "hw.ncpu:" {
	    print "Number of Processor Cores:", $2;
	}'

# physical memory
sysctl -n hw.physmem hw.usermem | awk -F' ' 'BEGIN{}
	NR==1 {
	    phy=$1;
	    print "Total Physical Memory:", $1/1024/1024/1024, "GB";
	}
	NR==2 {
	    print "Free Memory (%):", (1 - ($1 / phy)) * 100, "%"; 
	}'

echo "Total logged in users:" `who | cut -d' ' -f 1 | sort -u | wc -l`


