#! /bin/bash

fileLocation=$1
count=1 # variable to increment 
updatedFilesLocation=$2

touch $updatedFilesLocation # create file, doesn't clear it, if it exists
> $updatedFilesLocation # clear newFile

cat $fileLocation | while read line
do
    if [ -z "$line" ] || [[ "$line" == $'\r' ]] # catches blank lines or lines containing only \r 
    then
	#echo "we got a match"
	count=$((count+1))
	if [ $count -gt 2 ];
	then
	    count=1 # restart counter if current line is not blank
	    # if count is greater than 2,
	    # it means the script found two new lines
	    # that come one after the other.
	    # In this case, the script does not
	    # update $updatedFilesLocation
	else
	    # update $updatedFilesLocation if
	    # current line is empty but
	    # the count is less than 2
	    # ie the current empty line
	    # does not come immediately
	    # after an empty line

	    #echo "adding $line"
	    echo $line >> $updatedFilesLocation	    
	fi	
    else
	count=1
	# if current line is not empty,
	# restart count, to ensure that the
	# script only counts lines
	# that come one after the other

	# update $updatedFilesLocation
	#echo "adding $line"
	echo $line >> $updatedFilesLocation
    fi
done
	
