#! /bin/bash

# get options file
source opts.sh

# get authentication functions
source authenticationFunctions.sh

# get readFile function
source readFile.sh

# get helper functions
source helperFunctions.sh

# get writeToFile function
source writeToFile.sh

# file in google docs that will be updated 
sourceFile=$1
targetFile=$2


function appendToFile {
    # appends to doc file 
    # the string to append  will be the first argument 
    # the file being updated will be the second argument
    # ex: updateDocFile fileToUpload.txt docTargetFile.txt 

    update=$1
    targetFile=$2

    readFile $targetFile > /tmp/toUpload # read google doc file
    echo "$update" >> /tmp/toUpload # append new content to it
    
    writeToFile "$(cat /tmp/toUpload)" $targetFile
    rm /tmp/toUpload
}

# http://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced

if [[ "${BASH_SOURCE[0]}" == "${0}" ]] 
then
    # script is NOT being sourced ...
    checkAndGetCredentialsIfNeeded
    checkAndRenewTokenIfNeeded

    # Test
    if [ -z "$sourceFile" ] 
    then
	echo "file to upload?"
	read fileToUpload
    fi

    appendToFile $sourceFile $targetFile
fi

echo "DONE"
