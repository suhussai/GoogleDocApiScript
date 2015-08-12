#! /bin/bash



OPTIND=1
while getopts "h" OPTION
do

    case $OPTION in 
	h)
	    cat <<EOF

Usage:

./writeToGoogleDoc.sh sourceFile.txt destinationFileInGoogleDocs.txt

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




# file in google docs that will be updated 
sourceFile=$1
targetFile=$2
configFile="config"

function readDocFile {
    # downloads google docs file for updating
    # argument is the file to be read
    fileToRead=$1

    getFileID $fileToRead
    
    checkType $fileID
    
    if [ "$googleDocFormat" = true ]
    then
	curl -X GET -H "Authorization: Bearer $access_token" "https://docs.google.com/feeds/download/documents/export/Export?id=$fileID&exportFormat=txt" > /tmp/toUpload
    else
	curl -X GET -H "Authorization: Bearer $access_token"  https://www.googleapis.com/drive/v2/files/$fileID?alt=media > /tmp/toUpload	
    fi
    
    echo -e "\n" >> /tmp/toUpload
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

function getFileID {
    # gets file id of given file
    # getFileID file.txt
#    fileID=$(curl -X GET -H "Authorization: Bearer $access_token" https://www.googleapis.com/drive/v2/files | grep -B 20  $1 | grep -A 4 items | awk '/id/ {print $2}' | xargs)

    fileID=$(curl -X GET -H "Authorization: Bearer $access_token" https://www.googleapis.com/drive/v2/files | grep -m 1 -B 20 $1  | awk '/id/ {print $2}' | xargs | awk '// {print $1}')
    
    fileID="${fileID//,}"
}

function getRefreshToken {
    # need to update it so that we dont 
    # use code if refresh token exists
    # 
    refresh_token=$(curl -H "Content-Type: application/x-www-form-urlencoded" -d "code=$code&client_id=$client_id&client_secret=$client_secret&redirect_uri=$redirect_uri&grant_type=authorization_code" https://accounts.google.com/o/oauth2/token | awk '/refresh_token/ {print $3}' | xargs)
    
    refresh_token="${refresh_token//,}"
    echo "refresh_token is $refresh_token"
}


function getCredentials {
    # gets client_id, client_secret, redirect_uri
    # and code and saves it to config file
    fileCount=$(ls | egrep "^$configFile$")
    if [ -z "$fileCount" ]
    then
	echo "credentials not set..."

	echo "Navigate here: https://console.developers.google.com/project"
	echo "and enter your Client ID, Client Secret and Redirect Uri, as shown on that page"

	echo "Client ID:"
	read client_id

	echo "Client Secret:"
	read client_secret

	echo "Redirect Uri:"
	read redirect_uri
	
	echo "Navigate here: https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/drive&redirect_uri=$redirect_uri&response_type=code&client_id=$client_id"
	echo "and enter the code"	

	echo "Code:"
	read code

	saveCredentials
    fi	

}

function saveCredentials {
    # save credentials to a local file
    # so user only has to enter credentials
    # in the beginning
    fileName=$configFile

    echo "client_id = $client_id " > $fileName
    echo "client_secret = $client_secret" >> $fileName
    echo "redirect_uri = $redirect_uri" >> $fileName
    echo "code = $code" >> $fileName
    
}


function renewAccessToken {
    # Assuming client_id, client_secret, refresh_token is set
    # this function will update the access token variable
    access_token=$(curl -H "Content-Type: application/x-www-form-urlencoded" -d "client_id=$client_id&client_secret=$client_secret&refresh_token=$refresh_token&grant_type=refresh_token" https://accounts.google.com/o/oauth2/token | awk '/access_token/ {print $3}' | xargs)

    # trim last comma
    access_token="${access_token//,}"   

    sed -i "/access_token = */c\access_token = $access_token" $configFile
}

function checkType {
    # if file has a downloadUrl 
    # then the file type
    # is not a googleDocFormat
    #
    # it is some uploaded file 
    # with an extension like .txt
    
    fileID=$1
    value=$(curl -X GET -H "Authorization: Bearer $access_token" https://www.googleapis.com/drive/v2/files/$fileID | grep downloadUrl)

    if [ -z "$value" ]
    then
	googleDocFormat=true
    else
	googleDocFormat=false
    fi
}

function checkToken {
    # checks if token is expired
    # updates variable expired

    value=$(curl https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$access_token | awk '/expires_in/ {print $2}' | xargs)

    if [ -z "$value" ]
    then
	expired=true
    else
	expired=false
    fi
	
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
