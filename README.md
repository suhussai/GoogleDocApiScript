# GoogleDocApiScript
Script that appends to a specified file to in google docs

Requires: client_id, client_secret, redirect_uri, code,
  
Current Functionality
 
- can read a google doc file (.txt)
  and add to the content and upload it 
  back to google drive

Needs:
- funtionality to specify which file user wants to 
  update ---> done
 - perhaps display list of files available to user
- funtionality to upload file if file not present
  in google docs
- check if access_token needs refreshing ---> done

Future Functionality

- choose google doc title and create it and be upload via script

Usage:

./writeToGoogleDoc.sh uploadThisFilesContents.txt toThisFileInGoogleDocs.txt 

reference:
http://www.visualab.org/index.php/using-google-rest-api-for-analytics
