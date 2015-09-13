#! /bin/bash

# get options file
source opts.sh

# get authentication functions
source authenticationFunctions.sh

# get helper functions
source helperFunctions.sh

# file in google docs that will be updated 
sourceFile=$1
targetFile=$2



OPTIND=1
while getopts "h" OPTION
do

    case $OPTION in 
	h)
	    cat <<EOF

Usage:

./writeToGoogleDoc.sh sourceFile.txt destinationFileInGoogleDocs(.txt)

arg1 = local file that will be the update for the file in google docs

arg2 = the google docs file that will be updated with the contents of arg1

EOF
	    exit
	    ;;
	esac
done

# shift argument so that verbose options don't conflict with arguments 
# for script 
shift $((OPTIND-1))



function readDocFile {
    # downloads google docs file for updating
    # argument is the title of 
    # the file to be read

    fileToRead=$1

    getFileID $fileToRead
    
    checkType $fileID
    
    if [ "$googleDocFormat" = true ]
    then
	curl -X GET -H "Authorization: Bearer $access_token" "https://docs.google.com/feeds/download/documents/export/Export?id=$fileID&exportFormat=txt" > /tmp/tmpFile
	echo "" >> /tmp/tmpFile

	./lineFixer.sh /tmp/tmpFile /tmp/toUpload 
    else
	curl -X GET -H "Authorization: Bearer $access_token"  https://www.googleapis.com/drive/v2/files/$fileID?alt=media > /tmp/toUpload	
    fi
    
#    echo -e "\n" >> /tmp/toUpload
}

function updateDocFile {
    # updates doc file 
    # the update file will be the first argument 
    # the file being updated will be the second argument
    # ex: updateDocFile fileToUpload.txt docTargetFile.txt 

    update=$1
    targetFile=$2

    readDocFile $targetFile
    cat $update >> /tmp/toUpload

    #getFileID $targetFile
    curl -X PUT -H "Authorization: Bearer $access_token" --data-ascii "$(cat /tmp/toUpload)"  https://www.googleapis.com/upload/drive/v2/files/$fileID
    
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

    updateDocFile $sourceFile $targetFile
fi

echo "DONE"
