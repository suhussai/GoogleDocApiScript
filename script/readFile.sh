
function readFile {
    # downloads google docs file for updating
    # argument is the title of the file to be read

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
    
    cat /tmp/toUpload
}


# http://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced

if [[ "${BASH_SOURCE[0]}" == "${0}" ]] 
then
    # script is NOT being sourced ...
    checkAndGetCredentialsIfNeeded
    checkAndRenewTokenIfNeeded
    readFile $1
fi
