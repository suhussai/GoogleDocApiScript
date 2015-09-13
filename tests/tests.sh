cd ..
cd script/
source listFiles.sh
cd ../tests/

@test "Check if we can ping google.ca" {
    ping -c 4 google.ca
}

@test "listfiles in google directory" {
    checkAndGetCredentialsIfNeeded
    checkAndRenewTokenIfNeeded
    listFiles > /tmp/tmpFile
    # check /tmp/tmpFile

}
 
