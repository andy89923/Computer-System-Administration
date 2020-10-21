sockstat -4l | sed -e 1d | awk -F" " '{ print $3 " " $5 "_" $6 }' 
