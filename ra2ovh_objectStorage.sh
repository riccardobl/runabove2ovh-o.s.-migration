default="\e[0m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"

function usage {
    echo "[!] Usage: ./ra2ovh_objectStorage.sh [operation]"
    echo "[!] Operations:"
    echo "[!]   sync : do sync containers"
    echo "[!]   compare : compare containers"
    exit
}

if [ "$1" == "help" -o "$1" == "" ]
then
    usage
fi

if [ "$RA_PASS" == "" ]
then
    echo "[?] Please enter your Runabove Password: "
    read -sr RA_PASS
fi
if [ "$OVH_PASS" == "" ]
then
    echo "[?] Please enter your Ovh Password: "
    read -sr OVH_PASS
fi

function ra {
    source ./settings/ra-settings.sh
    export OS_REGION_NAME=$SOURCE_REGION
    export OS_PASSWORD=$RA_PASS
}

function ovh {
    source ./settings/ovh-settings.sh
    export OS_REGION_NAME=$TARGET_REGION
    export OS_PASSWORD=$OVH_PASS
}

ra
CONTAINERS=`swift list`
while read -r container
do 
    echo -e "[!] Container: $blue$container$default"
    if [ "$1" == "compare" ]
    then
        ra
        ra_objs=`swift list $container`
        mapfile -t ra_objs <<< "$ra_objs"
        ovh
        ovh_objs==`swift list $container`
        mapfile -t ovh_objs <<< "$ovh_objs"
        sync=1
        for o in "${ra_objs[@]}"
        do
            found=0
            for o2 in "${ovh_objs[@]}"
            do
                if [ "$o" == "$o2" ]
                then
                   found=1
                   break
                fi
            done
            if [ $found == 0 ]
            then
                sync=0
                echo -e "[-] $red'$o'$default is missing in OVH:$blue$container$default"
            fi            
        done
        if [ $sync == 1 ] 
        then
            echo -e "[+]$green Synchronized! $default"
        fi
      
    elif [ "$1" == "sync" ]
    then
        sharedKey=$(openssl rand -base64 32) 
        ovh
        swift post --sync-key "$sharedKey" $container
        destContainer=$(swift --debug stat $container 2>&1 | grep 'curl -i.*storage' | awk '{ print $4 }') 
        ra
        swift post --sync-key "$sharedKey" --sync-to "$destContainer" $container     
        echo -e "[+] Sync from RA:$blue$container$default to OVH:$blue$container$default"
    else
        usage
    fi
done <<< "$CONTAINERS" 