#!/bin/bash

if [ "$#" -ne 4 ]; then
    
    echo "Illegal number of parameters"
    echo "Usage: setupNewProject.sh  <api key> <project id>  <base dir for file uri> <working dir>"
    exit 0
fi


# globals
SL_APIKEY=$1
SL_PROJECT=$2
WORKING_DIR=$4

FT="javaProperties"
SL_DIRECTIVE_1="smartling.placeholder_format_custom=\{.+?\}|%%.+?%%"
SL_DIRECTIVE_2="smartling.placeholder_format=NONE"
SL_DIRECTIVE_3="smartling.string_format=NONE"


# $1 master english file
# $2 file uri
function upload
{

	local_en_file=$1
	sl_file_uri=$2

	sleep 10 
	set -x
	curl -F "file=@$local_en_file;type=text/plain" -F "apiKey=$SL_APIKEY" -F "projectId=$SL_PROJECT" -F "fileType=$FT" -F "fileUri=$sl_file_uri" -F "approved=true" -F "$SL_DIRECTIVE_1" -F "$SL_DIRECTIVE_2" -F "$SL_DIRECTIVE_3" "https://api.smartling.com/v1/file/upload"

	set +x
}




# $1 locale
# $2 lang only - file postfix
# $3 feature
function download
{

	SL_LOCALE=$1

	sleep 3
	set -x
	
	curl -d  "apiKey=$SL_APIKEY&projectId=$SL_PROJECT&fileUri=$SL_FILE_URI&locale=$SL_LOCALE" "https://api.smartling.com/v1/file/get" > "$3_$2.properties.downloaded"
	
	sort "$3_$2.properties.downloaded" > "$3_$2.properties.downloaded.sorted"
	rm -f "$3_$2.properties.downloaded"

	set +x
}





# heading-messages for example
cd $WORKING_DIR
CWD=$(pwd)

for D in *; do
    if [ -d "${D}" ]; then
        echo "about to process ${D} ..."   # your processing here


	BIL_FEATURE=${D}
	cd $CWD/$BIL_FEATURE
	
	#wix-premium/messages for example
	BIL_BASE_PATH=$3
	
	LOCAL_EN_FILE="$BIL_FEATURE"_en.properties

	SL_FILE_URI=$BIL_BASE_PATH/$BIL_FEATURE/$LOCAL_EN_FILE
	echo "fileUri="$SL_FILE_URI

	LOCAL_FILE_BN=$(basename $LOCAL_EN_FILE)
	echo $LOCAL_FILE_BN

#	upload $LOCAL_EN_FILE $SL_FILE_URI

	LOCALES="de-DE ru-RU it-IT ja-JP ko-KR pl-PL pt es tr-TR"

	for locale in $LOCALES
  	do
   		lang=${locale:0:2}
   		download $locale $lang $BIL_FEATURE
  	done  

	cd $CWD

	fi
done
