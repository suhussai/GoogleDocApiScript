
OPTIND=1
while getopts "h" OPTION
do

    case $OPTION in 
	h)
	    cat <<EOF

Usage:

./writeToGoogleDoc.sh sourceFile.txt destinationFileInGoogleDocs(.txt)

arg1 = local file that will be the update for the file in google docs

arg2 = the google docs file that will be updated with the contents of arg1

EOF
	    exit
	    ;;
	esac
done

# shift argument so that verbose options don't conflict with arguments 
# for script 
shift $((OPTIND-1))
