# get authentication functions
source authenticationFunctions.sh

# get helper functions
source helperFunctions.sh

# file in google docs that will be updated 
sourceFile=$1
targetFile=$2


function writeToFile {
    # writes to doc file 
    # the content to be written will be the first argument (string) 
    # the file being updated will be the second argument
    # ex: writeToFile "this will overwrite original" docTargetFile.txt

    content=$1
    targetFile=$2

    # get file id to upload it to google docs
    getFileID $targetFile

    # upload content to targetFile in google docs
    curl -X PUT -H "Authorization: Bearer $access_token" --data-ascii "$content"  https://www.googleapis.com/upload/drive/v2/files/$fileID
    

}

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

    writeToFile $sourceFile $targetFile
fi
