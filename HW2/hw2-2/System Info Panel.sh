# !/bin/sh

trap_ctrlc() {
    rm choose.tmp;
    echo "Ctrl + C pressed";
    exit 2;
}
trap "trap_ctrlc" 2;

LoginRank() {
    sh ./template/loginRank.sh > ./template/loginRank.txt;

    dialog  --clear --title "LOGIN RANK" \
            --textbox ./template/loginRank.txt 10 51

    rm ./template/loginRank.txt;
}

PortInfo() {
    ipv4s=`sockstat -4l | sed -e 1d | awk -F" " '{ print $3 " " $5 "_" $6 }'`;
    while : 
    do {
        pidSl=$(dialog  --clear --title "" \
                        --menu "PORT INFO(PID and Port)" 20 51 35 \
                        ${ipv4s} 2>&1 >/dev/tty)

        case $? in
            0)
                detail=`ps -cul ${pidSl} | sed 1d | awk -F' ' '{
                            print "USER:", $1, "\nPID:", $2, "\nPPID:", $13;
                            print "STAT:", $8, "\n%CPU:", $3, "\n%MEM:", $4;
                            print "COMMAND:", $11;
                        }'`; 
                dialog  --title "Process Status: ${pidSl}" \
                        --msgbox "${detail}" 15 51;;
            *)
                break;;
        esac
    } done
}

MountPointInfo() {
    motpo=`df -HT -t zfs,nfs | sed 1d | awk -F' ' '{ printf "%-30s %-30s\n", $1, $7; }'`;
    while :
    do {
	   motSl=$(dialog --clear --title "" \
                      --menu "MOUNTPOINT INFO" 30 60 35 \
                      ${motpo} 2>&1 >/dev/tty)

    	case $? in
            0)
        		detail=`df -HT -t zfs,nfs | grep ${motSl} | awk -F' ' '{
                            print "FileSystem:", $1, "\nType:", $2, "\nSize:", $3;
                            print "User:", $4, "\nAvail:", $5, "\nCapacity:", $6;
                            print "Mounted on:", $7;
                        }'`;
                dialog  --title "${motSl}" \
                        --msgbox "${detail}" 15 51;;
    	    *)
                break;;
    	esac
    } done
}

SaveSystemInfo() {
    pathSl=$(dialog --clear --title "SAVE TO FILE" \
                    --inputbox "Enter the path:" 10 50 2>&1 > /dev/tty)
    
    case $? in
        0)
            sh ./template/systemInfo.sh > ./template/systemInfo.txt;;
        *)
            return;;
    esac
	
	firstChar="$(echo $pathSl | head -c 1)";
    if [ "${firstChar}" = "/" -o "${firstChar}" = "~" ]; then
		
		crtDir=`echo $pathSl | rev | cut -d / -f 2- | rev`;

		if [ "${firstChar}" = "~" ]; then
			tmpath=`echo ${pathSl} | cut -c 3- | rev | cut -d / -f 2- | rev`;
			crtDir=`echo ~/${tmpath}`;
			pathSl=`echo ${pathSl} | rev | cut -d / -f 1 | rev`;
			pathSl=`echo ${crtDir}/${pathSl}`;
		fi
    else
		crtDir=`echo ~`;
		if [ "${pathSl}" = "" ]; then
			crtDir="";
		else
			crtDir=`echo ~/${pathSl} | rev | cut -d / -f 2- | rev`;
        	pathSl=`echo ~/${pathSl}`;
		fi
    fi
	
	# Not Exist directory
	if ! [ -d "${crtDir}" ]; then
		dialog 	--clear --title "Directory Not Found" \
				--msgbox "${crtDir} not found!" 10 50
		return;
	fi
	
	# Not writable dir or not writable file	
	if ! [  -w "${crtDir}" ]; then
		dialog  --clear --title "Permission Denied" \
				--msgbox "No Write Permission to ${crtDir}" 10 50
		return;
	fi
	if [ ! -e "${pathSl}" -o -w "${pathSl}" ]; then
	else	
		dialog  --clear --title "Permission Denied" \
				--msgbox "No Write Permission to ${pathSl}" 10 50
		return;
	fi

    cat ./template/systemInfo.txt > ${pathSl};
    echo "$(cat ./template/systemInfo.txt)" $'\n' $'\n' $'\n' "The Output file is saved to ${pathSl}" > tmp.txt;

    dialog  --clear --title "System Info" \
            --textbox tmp.txt 20 80;
    
    rm tmp.txt;
    rm ./template/systemInfo.txt;
}

LoadSystemInfo() {
    pathSl=$(dialog --clear --title "Load From File" \
		    --inputbox "Enter the path:" 10 50 2>&1 > /dev/tty)

    case $? in
		0) ;;
    	*) return;;
    esac

    firstChar="$(echo $pathSl | head -c 1)";
    if [ "$firstChar" = "~" ]; then
        pathSl=`echo $pathSl | cut -c 2-`;
        tmpHDp=`echo ~`;
		pathSl=`echo $tmpHDp$pathSl`;
    else
        if ! [ "$firstChar" = "/" ]; then
			pathSl=`echo ~/$pathSl`;
    	fi
	fi

	if ! [ -e "${pathSl}" ]; then
		dialog  --clear --title "File Not Found" \
				--msgbox "${pathSl} not found" 10 50
		return;
	fi

	if ! [ -r "${pathSl}" ]; then
		dialog  --clear --title "Permission Denied" \
				--msgbox "No read permission to ${pathSl}" 10 50;
		return;
	fi

	filNam=`echo ${pathSl} | rev | cut -d / -f -1 | rev`

    cat ${pathSl} > tmp.txt;
    dialog  --clear --title "${filNam}" \
            --textbox tmp.txt 20 80;

    rm tmp.txt;
}

Option() {
    Selection=`cat choose.tmp`
    case $Selection in
        1)
            LoginRank;
            echo "Login Rank";;
        2)
            PortInfo;
            echo "Port Info";;
        3)
            MountPointInfo;
            echo "MountPoint INFO";;
        4)
            SaveSystemInfo;
            echo "Save System Info";;
        5)
            LoadSystemInfo;
            echo "Load System Info";;
        *)
            echo "Error";;
    esac

    rm choose.tmp
}

main() {
    while :
    do {
        dialog  --stdout --no-collapse --title "System Tools" \
                --cancel-label "Exit" \
                --ok-label "Ok" \
                --menu "System Info Panel" 20 51 35 \
                        "1" "Login Rank" \
                        "2" "PORT INFO" \
                        "3" "MOUNTPOINT INFO" \
                        "4" "SAVE SYSTEM INFO" \
                        "5" "LOAD SYSTEM INFO" 2>&1 > choose.tmp
                        
        case $? in
            0)
                Option;
                echo "choice choosed";;
            1)
                rm choose.tmp;
                echo "exit";
                exit 0;;
            255)
                rm choose.tmp;
                echo "ESC pressed" >&2;
                exit 1;;
            *)
                echo "Somthing Wrong";;
        esac
    } done
}

main
