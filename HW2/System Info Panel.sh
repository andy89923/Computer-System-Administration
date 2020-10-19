# !/bin/sh

LoginRank() {

}

PortInfo() {

}

Option() {
    Selection=`cat choose.txt`
    case $Selection in
        1)
            LoginRank();
            echo "Login Rank";;
        2)
            PortInfo();
            echo "Port Info";;
        3)
            echo "MountPoint INFO";;
        4)
            echo "Save System Info";;
        5)
            echo "Load System Info";;
        *)
            echo "Error";;
    esac
}

main() {
    dialog --stdout --no-collapse --title "System Tools" \
        --cancel-label "Exit" \
        --ok-label "Ok" \
        --menu "System Info Panel" 20 51 35 \
            "1" "Login Rank" \
            "2" "PORT INFO" \
            "3" "MOUNTPOINT INFO" \
            "4" "SAVE SYSTEM INFO" \
            "5" "LOAD SYSTEM INFO" 2>&1 > choose.txt


    case $? in
        0)
            Option;
            echo "choice choosed";;
        1)
            echo "exit";
            return 0;
            exit;;
        255)
            echo "ESC pressed";;
        *)
            echo "Somthing Wrong";;
    esac
}

main
