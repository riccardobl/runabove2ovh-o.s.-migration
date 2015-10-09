# Runabove to OVH Object Storage migration script

This script will setup a syncronization between runabove and ovh containers (see [here](https://community.runabove.com/kb/en/object-storage/how-to-sync-runabove-object-storage-containers-to-ovh-public-cloud.html) for more info). 

## Requirements
To use this script you need GNU/Linux with `python-swift` `openssl` `curl` and `awk` installed.

Plus you need the ovh and runabove openrc.sh files.

You can find the runabove rc file inside `Horizon -> Access & Security -> API Access -> Download OpenStack RC file`.

While, to get the ovh's one you have to create a [new openstack user](https://www.ovh.com/fr/publiccloud/guides/g1773.creer_un_acces_a_horizon) inside `Gestion et conso. du projet` and then click the little sheet icon next to it.

## Usage
1. Clone this repo
2. Configure settings/ra-settings.sh and settings/ovh-settings.sh with the data you find inside openrc.sh files 
3. Run ra2ovh_objectStorage.sh 
4. Wait until the script ends

The script will create missing containers on ovh and will configure them to be syncronized with ra ones, after a while, if everything went correctly, you should see runabove starting to upload stuff to your ovh account.
