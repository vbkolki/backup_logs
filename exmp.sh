#!/bin/bash

# Current date stored to the variables seperately

d=$(date +"%d")
m=$(date +"%m")
y=$(date +"%Y")

# 2 days previous date stored to the variables seperately

dd=$(date --date="2 days ago" +"%d")
mm=$(date --date="2 days ago" +"%m")
yy=$(date --date="2 days ago" +"%Y")
#data="$y"-"$m"-"$d"

# Storing above seperated values in +%Y-%m-%d format into two_days variable

two_days="$yy"-"$mm"-"$dd"

# Grepping files with filename containing date in zips variable

zips=ls | grep -q "$today"
#===================================================================================

# Using for loop to check the files with two days previous date and Zip them using bzip2 format

for zips in *_*-${two_days}*.txt;
do

# Check for the date conditions less that present date
	if (((10#$yy == 10#$date) && (10#$mm <= 10#$date) && (10#$dd < 10#$date)))
then
	[ -f "${zips}" ] || continue     # If file exists continue
		
		date=${*-$zips}	        # Stores that file name in date variable	
		date=${*-$date}		# present date is saved to the date variable
	
	echo "${date}"	
	
#	bzip2 "${two_days}.bz2" *${two_days}*

	else
# zipping the file with two days previous file name to .bz2 extention

		bzip2 "${two_days}.bz2" *${two_days}*

	fi
done

