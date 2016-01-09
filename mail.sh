#===================================================================================

# Filename with the current date.
#today="$(date +%Y-%m-%d+%H-%M)"
today="$(date +%Y-%m-%d)"
final_output=report_log-$today.html; if [ -f "$final_output" ]; then rm "$final_output"; fi
#===================================================================================
#Aceess the log file, grep's the pattern using regex operation, calculates the percentage in ms with respect to 70%...so on.

awk '/update/' access_log.2015-12-23.txt | cut -d " " -f11 |



awk 'BEGIN {i=0} {s[i]=$1; i++;}  END {{print "Pattern""\t" "/sdk/api/updateDeviceConfiguration_v0/""\t";}; print "Count""\t" NR; print "70 "  s[int(NR*0.70-0.5)]; print "80 "  s[int(NR*0.80-0.5)]; print "90 "  s[int(NR*0.90-0.5)]; print "95 "  s[int(NR*0.95-0.5)]; print "99 " s[int(NR*0.99-0.5)]; print "100 " s[int(NR-1)]}' > filelog1.txt

# fetches the data from filelog1.txt and calculates the average time taken in ms and updates to avg1.txt.

awk '{sum+=$2} END { print "Average",sum/NR}t' filelog1.txt >avg1.txt

# Fetches the Average column from avg1.txt and adds to the main table in test3.txt

awk 'FNR==NR{ a[FNR]=$1; a[FNR]=$2}{print $2}' avg1.txt filelog1.txt > test3.txt

# Converts the format of table, Coloumns to Rows. And outputs it to the outfile.txt file.

awk '{ for (i = 1; i <= NF; i++) f[i] = f[i] "\t \t \t" $i ;
       if (NF > n) n = NF }

 END { for (i = 1; i <= n; i++) sub(/^  */, " ", f[i]) ;
       for (i = 1; i <= n; i++) print "\t"f[i] }
    ' test3.txt >outfile.txt

# Since from above awk command Average column will be attached at 1st Col, so swapping of Col to $11

awk ' { t = $1; $1 = $11; $11 = t; print; } ' outfile.txt > outfile3.txt

# #Creating HTML report for only those APIs in the pattern

#temp=temp.txt; if [ -f "$temp" ]; then rm "$temp"; fi
#output=outfile1.txt
#for file in ${output[@]}
#do
#	grep "$k" "$output" >> "$temp"
 #       sort -k2 -n "$temp" | awk 'BEGIN{print " <!DOCTYPE html> \n <html> \n <body> \n <table border=\"1\" style=\"width:100%\">"} {print "<tr>";for(i=1;i<=NF;i++)print "<td>" $i"</td>";print "</tr>"} END{print " </table> \n </body> \n </html>""\n"}'> $final_output
#done



#===================================================================================

# SAME AS ABOVE BUT FOR ANOTHER PATTERN

awk '/predictLocation/' access_log.2015-12-23.txt | cut -d " " -f11 |

awk 'BEGIN {i=0} {s[i]=$1; i++;}  END {{print "Pattern""\t" "/sdk/api/predictLocation_v0/""\t";} print "Count""\t" NR; print "70 "  s[int(NR*0.70-0.5)]; print "80 "  s[int(NR*0.80-0.5)]; print "90 "  s[int(NR*0.90-0.5)]; print "95 "  s[int(NR*0.95-0.5)]; print "99 " s[int(NR*0.99-0.5)]; print "100 " s[int(NR-1)]}' > filelog.txt

awk '{sum+=$2} END { print "Average",sum/NR}t' filelog.txt >avg.txt

awk 'FNR==NR{ a[FNR]=$1; a[FNR]=$2}{print $1,$2}' avg.txt filelog.txt > test5.txt

awk '{ for (i = 1; i <= NF; i++) f[i] = f[i] "\t \t \t" $i ;
       if (NF > n) n = NF }

 END { for (i = 1; i <= n; i++) sub(/^  */, " ", f[i]) ;
       for (i = 1; i <= n; i++) print "\t"f[i] }
    ' test5.txt >outfile2.txt

awk ' { t = $1; $1 = $11; $11 = t; print; } ' outfile2.txt >> outfile3.txt

temp1=temp1.txt; if [ -f "$temp1" ]; then rm "$temp1"; fi
output1=outfile3.txt
for file in ${output1[@]}
do
        grep "$k" "$output1" >> "$temp1"
        sort -k2 -n "$temp1" | awk 'BEGIN{print " <!DOCTYPE html> \n <html> \n <body> \n <table border=\"1\" style=\"width:100%\">"} {print "<tr>";for(i=1;i<=NF;i++)print "<td>" $i"</td>";print "</tr>"} END{print " </table> \n </body> \n </html>"}'>> $final_output
done

#===================================================================================

#sENDING EMAIL TO THE SPECIFIED MAIL ID

body=body.sh
to_email=eamil.txt

#mail -s "Your Subject" vishwanath@getfocus.in < final_output.html

#mutt "$to_email" <$body -s "Report for access_log for $date1 " -a final_output.html


echo "Sending mail"

echo "Report for access_log of $(hostname) for $(date) " | mutt vishwanath@getfocus.in -s Log Report -a $final_output

# Checks if mail is sent or not by using if condition

if [ $? -eq 0 ]; then echo "mail sent"; else echo "mail sending failed"; fi

#echo "mail sent Successfully"
#===================================================================================

# Removes the files after the use

rm $output $temp $final_output outfile3.txt
#===================================================================================#===================================END=============================================
