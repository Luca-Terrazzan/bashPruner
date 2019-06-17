#!/bin/sh
#####
#
# Deletes files in a folder based upon age since their last edit time
# Please set a age limit and a base path before using.
#
# Usage:
# $ ./prune.sh                  |--> Deletes all files older than 5 days in the current folder
# $ ./prune.sh -p <path>        |--> Provides a custom path
# $ ./prune.sh -a <seconds>     |--> Provides a custom age in seconds
# $ ./prune.sh -s               |--> Safe mode, actually delete files. Use this after testing.
#
#####

echo "Start pruning..."

#####
# Setup prune configuration, all settings are rewritable at runtime trhough their options
# Maximum allowed file age in seconds
agelimit=999999999
# Path to the folder being pruned
basepath="."
# Safemode, if set to 1 no actual removal is performed
safemode=1
#####

# Parse options, if any
while getopts "p:a:s" flag; do
  case "${flag}" in
    p) basepath="${OPTARG}" ;;
    a) agelimit="${OPTARG}" ;;
    s) safemode=0 ;;
  esac
done

# Check if the basepath is a valid directory
if ! [ -d "$basepath" ]; then
    echo "$basepath is not a valid directory. aborting."
    exit
fi

for filename in "$basepath"/*; do

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

  # Try to get the last status edit date with linux syntax
  filelasteditdate=`stat -c "%Z" "$filename" 2>/dev/null`
  if ! [ $? -eq 0 ]; then
    # If that doesn't work, use OSX syntax
    echo 'Using mac mode'
    filelasteditdate=`stat -f "%c" "$filename"`
  fi

  # Cannot get file age, return with error
  if ! [ $? -eq 0 ]; then
    echo "Cannot get file information. Make sure that stat is an available program on this machine"
    exit -1
  fi

  # Calculate file age
  currenttime=`date +%s`
  fileage=$((currenttime-filelasteditdate))

  echo "$filename is $fileage seconds old"

  # Remove if older than threshold
  if [ $fileage -gt $agelimit ]; then
    echo "$filename is older than $agelimit seconds, removing..."

    # Actually remove files only if safemode is disabled
    if [ $safemode -eq 0 ]; then
      rm "$filename"
    fi
    echo "$filename removed"

  # Otherwise do nothing
  else
    echo "$filename is younger than $agelimit seconds, keeping..."
  fi

done

echo "Pruning completed!"
