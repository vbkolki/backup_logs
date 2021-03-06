#!/bin/bash

#date="$(date "+%Y-%m-%d")"

zips=ls | grep "$today"     # grep filename containing date
      
ten_days=$(date -d "2 days ago" +%Y-%m-%-d) # Date 0f 2 days previous is taken into a variable ten_days

for zips in *_*-${ten_days}*.txt; # for loop matches the string of file name with date
do
	if ((${ten_days} -lt ${date}))
#	if (($((10#($ten_days))) -lt ${date}))   # Checks the condition with present date
	then
		 [ -f "${zips}" ] || continue # If file exists continue
        	 date=${*-$zips}          # Stores it into a date variable
        	 date=${*-$date}       # Date variable is checked and added to date variable
       		 echo "${date}" 

#  (( $date < $ten_days )) && rm "$f"

	 	 bzip2  "${ten_days}.bz2" *${ten_days}* # zip the file with the date

        else
       		 echo "Already Compressed" 
 	fi

done

#sudo rm -f $zips
