#!/bin/bash

backup_dir=/home/vishwa/backup/

tput setaf 1 ;
echo "This is tar dump directory file path you are using"
echo "$backup_dir"
echo " "
echo "The restore will happen from this above directory, so change it according to your path"
echo " "
echo "Edit the tar directory path in script under variable : backup_dir "

read -p "Do you want to Continue (y/n)?" CONT

if [ "$CONT" == "y" ]; then
  echo "proceed";
else
  tput sgr0; # Reset text format to the terminal's default
  exit;
fi
echo "hi"
tput sgr0;    # Reset text format to the terminal's default

