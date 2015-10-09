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
    echo "[!] Container: $container"
    if [ "$1" == "compare" ]
    then
        ra
        ra_objs=`swift list $container`
        ovh
        ovh_objs=`swift list $container`
        if [ "$ra_objs" = "$ovh_objs" ]
        then
            echo "[+] Synchronized"
        else
            echo "[-] Not synchronized"
        fi       
    elif [ "$1" == "sync" ]
    then
        sharedKey=$(openssl rand -base64 32) 
        ovh
        swift post --sync-key "$sharedKey" $container
        destContainer=$(swift --debug stat $container 2>&1 | grep 'curl -i.*storage' | awk '{ print $4 }') 
        ra
        swift post --sync-key "$sharedKey" --sync-to "$destContainer" $container     
        echo "[+] Sync from RA:$container to OVH:$destContainer"
    else
        usage
    fi
done <<< "$CONTAINERS" 