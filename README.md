# GoogleDocApiScript
Script that appends to a specified file to in google docs

Requires: client_id, client_secret, redirect_uri, code,

  
Current Functionality
- guides user through getting require parameters, and saves
  the credentials in a local config file. 
- Refreshes access token whenever it expires
- Requires credentials to be set only once
- can read a google doc file (.txt)  or native google doc files
  and add to the content and upload it 
  back to google drive
- can also read and update google docs native format file (buggy)
- added -h help feature that shows basic usage info

TODO:
- separated logical components into different files --> done
- funtionality to specify which file user wants to 
  update ---> done
 - perhaps display list of files available to user
- funtionality to upload file if file not present
  in google docs
- check if access_token needs refreshing ---> done
- move into separate files for easier organization
- choose google doc title and create it and be upload via script

Usage:

./writeToGoogleDoc.sh uploadThisFilesContents.txt toThisFileInGoogleDocs.txt 

reference:
http://www.visualab.org/index.php/using-google-rest-api-for-analytics
