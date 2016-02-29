#!/bin/bash
#===================================================================================
			# ACCESS_LOG REPORT GENERATION #
#===================================================================================

# Acquiring Lock for the process

lockfile=/var/tmp/mylock

if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null; then

        trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
cat $lockfile
#==========================================================================

# Variable for accessing 1 day previous files and saving the output with desired file name.

one_day=$(date -d "1 days ago" +%Y-%m-%d)
#final_output=release_1a_lms_access_log.${one_day}.html; if [ -f "$final_output" ]; then rm "$final_output"; fi

#===================================================================================
# Getting the log contents from different location into a single map.
# Appending the logs with and without status 200 in a single map.
# Status which dont have status 200 are appended with error code to the pattern.

log_files=logmap.txt
file=*access_log.2015-08-20.txt
declare -a cols

#awk '{print $7 " " $11}' *_access_log.2015-08-20.txt > "$awklog"
if  [ -f $file ]
then
	grep -E '/sdk/api/*|/admin/*|/map/api/*' *access_log.2015-08-20.txt | grep -E '200' | awk '{print $7 " " $11}' >> "$log_files"
	
	grep -E '/sdk/api/*|/admin/*|/map/api/*' *access_log.2015-08-20.txt | grep -v '200' | awk '{print  $7"_error_"$9 " " $11}' >> "$log_files"
else
	(exit 20);
	echo "exit : $?"	
fi	

#grep -E '/sdk/api/*|/admin/*|/map/api/*' *access_log.2015-08-20.txt | grep -v '200' | awk '{print  $7"_error_"$9 " " $11}' >> "$log_files"
if [ -f $log_files ]
then

		while read rtime path; 
		do
			cols[$path]=$rtime

		done < "$log_files"
else
	(exit 21);
	echo "exit : $?"
fi
		
		for key in "${!cols[@]}"; 
		do 
			printf "%s\t%s\n" "${cols[$key]}" "$key";

		done > "$log_files"

#===================================================================================
output=output.txt
avg=avg.txt
temp=temp.txt

temp1=$(cat logmap.txt | cut -d " " -f 1 | sort -n | uniq)

#awk '{print $7 " " $9 " " $11 }' access_log.2015-08-20.txt | sort | uniq -u > outfile.txt 

# On the basis of patterns sorts and finds unique ones and finds the percentile of 70%, 80%..... so on.

for p in "${log_files[@]}"
do
        api_arr=($(awk '{print $1}' "$p" | sort | uniq))

        for j in "${api_arr[@]}"
        do
                printf "%s  " "$j" >> "$output"
                grep "$j" "$p" | sort -n -k2 | awk 'BEGIN{i=0} {s[i]=$2; i++;} END {printf "%d %d %d %d %d %d %d \n" , NR,s[int(NR*0.70-0.5)], s[int(NR*0.80 - 0.5)],s[int(NR*0.90 -0.5)],s[int(NR*0.95-0.5)] ,s[int(NR*0.99 -0.5)], s[int (NR -1)] }'>> "$output"
		grep "$j" "$p" | cut -d " " -f2 | awk '{{sum+=$2};} END { print sum/NR}t' >> "$avg"
        done
done

if [ -f $output ]
then
		paste "$output" "$avg" >> "$temp"
else
	(exit 22);
	echo "exit : $?"
fi

if [ -f $output ]
then
		printf "API Count 70 80 90 95 99 100 Average \n" >> "$temp"
else
	(exit 23);
	echo "exit : $?"
fi
#===================================================================================
final=final.txt

# Get the output into HTML table.

if [ -f $temp ]
then

for k in "${temp1[@]}"
do
        grep "$k" "$temp" >> "$temp"
        sort -k2 -n "$temp" | awk 'BEGIN{print " <!DOCTYPE html> <html> \n <body> \n <table border=\"1\" style=\"width:100%\">"} {print "<tr>";for(i=1;i<=NF;i++)print "<td>" $i"</td>";print "</tr>"} END{print "</table> \n </body> \n </html>"}'> "$final"

done
else
	(exit 24);
	echo "exit : $?"
fi

#===================================================================================
# Mail the report generated in HTML format through SMTP server.

if [ -f $final ]
then
	echo "Report for access_log of $(hostname) for $(date) " | cat $final | mutt -c vishwanath@getfocus.in -s "Log Report for the $(date)" -e "set content_type=text/html"
else
	(exit 25);
	echo "exit : $?"
fi

# Remove files

if [ -f $final ]
then
	rm $output $final $avg $log_files $temp
else
	(exit 26);
	echo "No files were created to delete : $?"
fi

#====================================================================================

# Releasing Lock for the system

rm -f "$lockfile"
        trap - INT TERM EXIT
else
        echo "Lock Exists: $lockfile owned by $(cat $lockfile)"
fi

#==========================================================================
# ERROR CODES

# 0 - Successful
# 1 - Not Successfull
# 20 - File not found
# 21 - Files not created, can't remove
# 22 - No file found for PASTE command
# 23 - Temp file not created
# 24 - HTML file not created
# 25 - No file present to MAIL
# 26 - Files not created, Can't remove
