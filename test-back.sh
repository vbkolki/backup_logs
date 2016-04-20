#!/bin/bash

###################################################################################
                        #### CASSANDRA BACKUP SCRIPT ####
###################################################################################

cd /var/lib/cassandra/data/
backup_dir=/home/vishwa/backup/
today_date=$(date +'%Y-%m-%d')
data_dir=/var/lib/cassandra/data/

backup_snapshot_dir="$backup_dir/$today_date"
backup_schema_dir="$backup_dir/$today_date/SCHEMA"

###################### Create / check backup Directory ##########################

if [ -d  "$backup_schema_dir" ]
then
    echo "$backup_schema_dir already exist"
else
    mkdir -p "$backup_schema_dir"
fi

if [ -d  "$backup_schema_dir" ]
then
     echo "$backup_schema_dir already exist"
else
    mkdir -p "$backup_schema_dir"
fi

########################## SCHEMA BACKUP #########################################

#str=$(ls | grep 'lps')
#echo $str
#cd ~

str=("lps_live" "lps_map")

#for i in lps_live lps_map
for i in ${str[@]}
do
    if [ -d $i ]
then
        cqlsh -e "DESC KEYSPACE $i" > $backup_schema_dir/${i}_schema_${today_date}.txt
else
	echo "directory $i does not exist"
fi
done

################## Condition Checking to Proceed or not ############################################

echo "These are keyspaces you working on : "

printf '%s\t' "${str[@]}"

echo " "
echo " "

read -p "Do you want to Continue (y/n)?" CONT

if [ "$CONT" == "y" ]; then
  echo "proceed";
else
  exit;
fi


######################### CLEAR SNAPSHOT ###########################################

nodetool clearsnapshot

######################### TAKE SNAPSHOT ############################################

#nodetool snapshot -t $snapshot_name
for i in ${str[@]}
do
	nodetool snapshot $i
done

############ CREATE DIRECTORY STRUCTURE AS KEYSPACE AND COLUMN-FAMILY ##############

#for i in lps_live lps_map
for i in ${str[@]}
do
    if [ -d $i ]
then
        var=$(ls $data_dir/$i) # Change the path as the cassandra data path 
        for j in $var
        do
                if [ -d $j ]
                then
                        echo "$j Exists"
                else
                        mkdir -p $backup_snapshot_dir/$i/$j/snapshots
                        sudo cp -R  $data_dir/$i/$j/snapshots/* $backup_snapshot_dir/$i/$j/snapshots
                fi
	done
	fi
done

sleep 15
######################## TAR THE GENERATED BACKUP FOLDER ###########################
cd /home/vishwa/backup
 tar -cvf $today_date.tar.gz $today_date
####################### REMOVE THE DATED BACKUP DIRECTORY ##########################

sudo rm -rf $today_date

############################# UPLOAD ZIPPED FILE TO S3 #############################

#aws s3 cp $today_date.tar.gz s3://release-log-backup-bucket/LMS/${pub_ip}/$dir_day/ --recursive

################################# END OF SCRIPT ####################################
