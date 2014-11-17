#!/bin/bash

if [ "$#" -ne 2 ]; then
    
    echo "Illegal number of parameters"
    echo "Usage: sortRepo.sh   <base dir for file uri> <working dir>"
    exit 0
fi


# globals
WORKING_DIR=$2




# $1 locale
# $2 lang only - file postfix
# $3 feature
function diff_func
{


	SL_LOCALE=$1
	IMPORT_FILE="$3"_"$2".properties
	#IMPORT_FILE_BN=$(basename $IMPORT_FILE)
	echo $IMPORT_FILE

	FILE_FROM_REPO="$3_$2.properties.sorted"
	FILE_FROM_SMARTLING="$3_$2.properties.downloaded.sorted"
	
	
	if diff -y -w $FILE_FROM_REPO $FILE_FROM_SMARTLING >/dev/null ; then
 		 echo "$FILE_FROM_REPO and $FILE_FROM_SMARTLING => same"
	else
		echo "$FILE_FROM_REPO $FILE_FROM_SMARTLING => different"
		diff $FILE_FROM_REPO $FILE_FROM_SMARTLING > $FILE_FROM_REPO.diff 

	fi
	#set -x
	#result=$(diff -y $FILE_FROM_REPO $FILE_FROM_SMARTLING)
   	#set +x
   	#echo "result=$result"
       
#   then
#     echo "Files are the sames"
#   else
#     echo "Files are differents"
#     echo "$result"
#   fi
	
	
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
	BIL_BASE_PATH=$1
	
	LOCAL_EN_FILE="$BIL_FEATURE"_en.properties

	SL_FILE_URI=$BIL_BASE_PATH/$BIL_FEATURE/$LOCAL_EN_FILE
	echo "fileUri="$SL_FILE_URI

	LOCAL_FILE_BN=$(basename $LOCAL_EN_FILE)
	echo $LOCAL_FILE_BN

#	upload $LOCAL_EN_FILE $SL_FILE_URI

	LOCALES="de-DE fr-FR it-IT ja-JP ko-KR pl-PL pt es tr-TR ru-RU"
	#LOCALES="fr-FR"

	for locale in $LOCALES
  	do
   		lang=${locale:0:2}
   		diff_func $locale $lang $BIL_FEATURE
  	done  

	cd $CWD

	fi
done
