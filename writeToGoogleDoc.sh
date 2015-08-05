#! /bin/bash

#  Requires: client_id, client_secret, redirect_uri, code,
#  
#
#
# current functionality
# 
# - can read a google doc file (.txt)
#   and add to the content and upload it 
#   back to google drive
# - currently needs refresh_token to be set manually
# 
# Needs
# - needs file I/O handling 
# - be able to save variables
#
# future functionality
#
# - choose google doc title and create it and be upload via script
# - check how much time left till access token
#   expiration and renew if about to expire


# reference
# http://www.visualab.org/index.php/using-google-rest-api-for-analytics

# file in google docs that will be updated 
#docsFile="scriptTesting"
docsFile="results"
fileToUpload=$1


function readDocFile {
    # downloads google docs file for updating
    getFileID
    curl -X GET -H "Authorization: Bearer $access_token"  https://www.googleapis.com/drive/v2/files/$fileID?alt=media > /tmp/toUpload
    echo -e "\n" >> /tmp/toUpload
}

function updateDocFile {
    # updates doc file 
    # the update file will be the first argument 
    # ex: updateDocFile "new addition to doc file" 

    update=$1

    readDocFile
    cat $update >> /tmp/toUpload

    getFileID
    curl -X PUT -H "Authorization: Bearer $access_token" --data-ascii "$(cat /tmp/toUpload)"  https://www.googleapis.com/upload/drive/v2/files/$fileID
    
}

function getFileID {
    fileID=$(curl -X GET -H "Authorization: Bearer $access_token" https://www.googleapis.com/drive/v2/files | grep -B 20  $docsFile | grep -A 4 items | awk '/id/ {print $2}' | xargs)
    
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
    fileCount=$(ls | egrep "^credentials$")
    if [ -z "$fileCount" ]
    then

	echo "Client ID:"
	read client_id

	echo "Client Secret:"
	read client_secret

	echo "redirect uri:"
	read redirect_uri
	
	echo "Go here: https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/drive&redirect_uri=$redirect_uri&response_type=code&client_id=$client_id"
	echo "and give me the code:"	

	echo "code:"
	read code

	saveCredentials
    fi	

}

function saveCredentials {
    # save credentials to a local file
    # so user only has to enter credentials
    # in the beginning

    # generate random file name
    fileName=credentials

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

    echo "access_token is $access_token"

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

client_id=$(cat credentials | awk '/client_id/ {print $3}')
if [ -z "$client_id" ]
then
    getCredentials
else
    client_secret=$(cat credentials | awk '/client_secret/ {print $3}')
    redirect_uri=$(cat credentials | awk '/redirect_uri/ {print $3}')
    code=$(cat credentials | awk '/code/ {print $3}')
    refresh_token=$(cat credentials | awk '/refresh_token/ {print $3}')
fi


checkToken 

if [ "$expired" = true ]
then
    refresh_token=$(cat credentials | awk '/refresh_token/ {print $3}')
    if [ -z "$refresh_token" ]
    then
	getRefreshToken
	echo "refresh_token = $refresh_token" >> credentials
    fi
    
    renewAccessToken
fi

# Test
if [ -z "$fileToUpload" ] 
then
    echo "file to upload?"
    read fileToUpload
fi

updateDocFile $fileToUpload
#echo "Sceptic/realist: prolly not" >> uploadThis
#updateDocFile "uploadThis"

echo "DONE"
