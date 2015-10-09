echo "Please enter your Runabove Password: "
read -sr RA_PASS
echo "Please enter your Runabove Ovh Password: "
read -sr OVH_PASS

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
    echo "Container: $container"
    sharedKey=$(openssl rand -base64 32) 
    ovh
    swift post --sync-key "$sharedKey" $container
    destContainer=$(swift --debug stat $container 2>&1 | grep 'curl -i.*storage' | awk '{ print $4 }') 
    ra
    swift post --sync-key "$sharedKey" --sync-to "$destContainer" $container     
    echo "Sync from RA:$container to OVH:$destContainer"
done <<< "$CONTAINERS" 