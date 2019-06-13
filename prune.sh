#!/bin/sh
#####
#
# Deletes files in a folder based upon age since their last edit time
#
# Usage:
# $ ./prune.sh                  |--> Deletes all files older than 5 days in the current folder
# $ ./prune.sh -p <path>        |--> Provides a custom path
# $ ./prune.sh -a <seconds>     |--> Provides a custom age in seconds
# $ ./prune.sh -s               |--> Safe mode, doesn't actually delete files. Use this to test.
#
#####

echo "Start pruning..."

agelimit=432000
basepath="."
safemode=0

# Parse options, if any
while getopts "p:a:s" flag; do
  case "${flag}" in
    p) basepath="${OPTARG}" ;;
    a) agelimit="${OPTARG}" ;;
    s) safemode=1 ;;
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

  # Do not self-destruct please
  if [ "$filename" == "$0" ]; then
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

    # Actually remove files only if safemode is disabled
    if [ $safemode -eq 0 ]; then
      rm $filename
    fi
    echo "$filename removed"

  # Otherwise do nothing
  else
    echo "$filename is younger than $agelimit seconds, keeping..."
  fi

done

echo "Pruning completed!"
