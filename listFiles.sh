#! /bin/bash


source authenticationFunctions.sh
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

    cat files.txt
    rm files.txt tmpfiles.txt tmpfiles2.txt tmpfiles3.txt
}


listDocFiles "$documents"
