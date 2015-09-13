load script/listFiles

@test "Check if we can ping google.ca" {
    ping -c 4 google.ca
}

@test "Check if we can ping google drive: https://drive.google.com/" {
    ping -c 4 https://drive.google.com/
}

@test "listfiles in google directory" {

}
 
