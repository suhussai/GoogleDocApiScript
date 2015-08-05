# GoogleDocApiScript
Script that appends to a specified file to in google docs

Requires: client_id, client_secret, redirect_uri, code,
  
current functionality
 
- can read a google doc file (.txt)
  and add to the content and upload it 
  back to google drive
- currently needs refresh_token to be set manually

Needs
- needs file I/O handling 
- be able to save variables

future functionality

- choose google doc title and create it and be upload via script
- check how much time left till access token
  expiration and renew if about to expire
