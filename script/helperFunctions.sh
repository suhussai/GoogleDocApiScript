configFile="../script/config"

function checkType {
    # checks if a file is 
    # of googledoc type format
    # or otherwise
    #
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
