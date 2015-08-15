#! /bin/bash


source authenticationFunctions.sh

source helperFunctions.sh
IFS=","
documents="vnd.google-apps.document,plain"

function listDocFiles {
    
    types=$1

    curl -X GET -H "Authorization: Bearer $access_token" https://www.googleapis.com/drive/v2/files/ > tmpfiles.txt

    # remove all folders from selection
    cat tmpfiles.txt | grep -A 5 title | grep -v folder | grep -A 5 title > tmpfiles2.txt

    # get only types we want
    for type in $types 
    do
	if [ -z "$searchTerm" ] 
	then
	    searchTerm="$type"
	else
	    searchTerm="$searchTerm\|$type"
	fi
    done
    
    cat tmpfiles2.txt | grep -B 1 -A 4 $searchTerm > tmpfiles3.txt

    # extract only titles and sort and filter out any duplicates
    cat tmpfiles3.txt | grep title | sort -u > files.txt

    rm tmpfiles.txt tmpfiles2.txt tmpfiles3.txt
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

listDocFiles "$documents"
