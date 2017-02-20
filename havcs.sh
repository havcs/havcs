#!/bin/bash

DATE_TIME=`date "+%Y-%m-%d_%H-%M-%S"`
FILE_IN="$2"
BACKUP_DIR="/Users/stephen/.havcs/files"
FILE_OUT=`echo $FILE_IN | tr / _`"_-_"${DATE_TIME}
OPTION="$3"
NUMBER="$4"

# FILE_NAME="${FILE_IN##*/}"
# echo ${FILE_NAME}

function edit {
    TMP_FILE="/tmp/"${FILE_OUT}".tmp"
    cp ${FILE_IN} ${TMP_FILE} # copy file to /tmp

    nano ${FILE_IN} # edit file

    if diff ${FILE_IN} ${TMP_FILE} >/dev/null ; then # check if file changed
      echo "File not changed"
    else
        BACKUP_FILE=${BACKUP_DIR}"/"${FILE_OUT}".hvc" # move tmp to backup
        mv ${TMP_FILE} ${BACKUP_FILE}
    fi
}

function list {
    i=0
    echo "available versions for "${FILE_IN}
    for file in ${BACKUP_DIR}/`echo $FILE_IN | tr / _`* # get all backup files for this input
        do
        if [[ -f $file ]]; then
            OUTPUT=${file##*_-_} # remove text before _-_
            OUTPUT=${OUTPUT%.*} # remove .hvc
            echo ${i}": "${OUTPUT}
            ((i++))
        fi
    done
}

function restore {

    if [[ ${OPTION} == "-n" ]]; then
        i=0 # this loop gets the filename of the version to be restored
        for file in ${BACKUP_DIR}/`echo $FILE_IN | tr / _`* # get all backup files for this input
            do
            if [[ $i == ${NUMBER} ]]; then
                TO_RESTORE=${file}
                break
            fi
            if [[ -f $file ]]; then
                ((i++))
            fi
        done
        TMP_FILE="/tmp/"${FILE_OUT}".tmp"
        cp ${FILE_IN} ${TMP_FILE} # copy file to /tmp
        cp ${TO_RESTORE} ${FILE_IN}
        rm ${TMP_FILE}
    else
        echo "Invalid operation "${OPTION}"!"
        exit
    fi
}

case "$1" in
    "-e") edit ;;
    "-l") list ;;
    "-r") restore ;;
    *) invalid ;;
esac
