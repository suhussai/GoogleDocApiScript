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

client_id=$(cat $configFile 2>/dev/null | awk '/client_id/ {print $3}')
if [ -z "$client_id" ]
then
    getCredentials
else
    client_secret=$(cat $configFile | awk '/client_secret/ {print $3}')
    redirect_uri=$(cat $configFile | awk '/redirect_uri/ {print $3}')
    code=$(cat $configFile | awk '/code/ {print $3}')
    refresh_token=$(cat $configFile | awk '/refresh_token/ {print $3}')
    access_token=$(cat $configFile | awk '/access_token/ {print $3}')
fi


checkToken 

if [ "$expired" = true ]
then
    refresh_token=$(cat $configFile | awk '/refresh_token/ {print $3}')
    if [ -z "$refresh_token" ]
    then
	getRefreshToken
	echo "refresh_token = $refresh_token" >> $configFile
    fi
    
    renewAccessToken
fi

# Test
if [ -z "$sourceFile" ] 
then
    echo "file to upload?"
    read fileToUpload
fi


updateDocFile $sourceFile $targetFile

echo "DONE"
