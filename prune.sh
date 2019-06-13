#!/bin/sh
#####
#
# Deletes files in a folder based upon age since their last edit time
#
# Usage:
# $ ./prune.sh                  |--> Deletes all files older than 5 days in the current folder
# $ ./prune.sh -p <path>        |--> Provides a custom path
# $ ./prune.sh -a <seconds>     |--> Provides a custom age in seconds
#
#####

echo "Start pruning..."

agelimit=432000
basepath="."

# Parse options, if any
while getopts "p:a:" flag; do
  case "${flag}" in
    p) basepath="${OPTARG}" ;;
    a) agelimit="${OPTARG}" ;;
  esac
done

# Check if the basepath is a valid directory
if ! [ -d "$basepath" ]; then
    echo "$basepath is not a valid directory. aborting."
    exit
fi

for filename in $basepath/*; do

  # Invalid file or empty folder, continue
  [ -e "$filename" ] || continue

  # Ignore directories
  if [ -d "$filename" ]; then
    echo "$filename is a directory, ignoring."
    continue
  fi

  # Calculate file age
  filelasteditdate=`date -r $filename +%s`
  currenttime=`date +%s`
  fileage=$((currenttime-filelasteditdate))

  echo "$filename is $fileage seconds old"

  # Remove if older than threshold
  if [ $fileage -gt $agelimit ]; then
    echo "$filename is older than $agelimit seconds, removing..."
    rm $filename
    echo "$filename removed"
  # Otherwise do nothing
  else
    echo "$filename is younger than $agelimit seconds, keeping..."
  fi

done

echo "Pruning completed!"
