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
    lines=$(cat /tmp/tmpFile | wc -l) 
    [ "$lines" -ge 0 ]
}

@test "create empty test file in google docs" {
    skip "Not yet implemented"
    
    listFiles > /tmp/tmpFile
    count=$(grep -c "testFile" /tmp/tmpFile)
    [ "$count" -eq 0 ]
    
    checkAndGetCredentialsIfNeeded
    checkAndRenewTokenIfNeeded
    creatFile "testFile"    
    
    listFiles > /tmp/tmpFile
    count=$(grep -c "testFile" /tmp/tmpFile)
    [ "$count" -eq 1 ]
}

@test "write and read test file" {
    skip "Not yet implemented"

    readFile "testFile" > /tmp/testFileContents
    contents=$(cat /tmp/testFileContents)
    [ "$contents" == "" ]    

    writeToFile "test content" "testFile"

    readFile "testFile" > /tmp/testFileContents    
    contents=$(cat /tmp/testFileContents)
    [ "$contents" == "test content" ]    

}

@test "append content to test file" {
    skip "Not yet implemented"

    appendToFile "test content on second line" "testFile"

    readFile "testFile" > /tmp/testFileContents    
    contents=$(cat /tmp/testFileContents)
    [ "$contents" == "test content\ntest content on second line" ]    


}

@test "delete test file" {
    skip "Not yet implemented"
    
    listFiles > /tmp/tmpFile
    count=$(grep -c "testFile" /tmp/tmpFile)
    [ "$count" -eq 1 ]

    deleteFile "testFile"
    
    listFiles > /tmp/tmpFile
    count=$(grep -c "testFile" /tmp/tmpFile)
    [ "$count" -eq 0 ]

}
 

