#!/bin/bash

folder="$1"

if ! [ -d ${folder}/test ]
then
    echo "test folder not found"
    exit 1
fi

if ! [ -d ${folder}/train ]
then
    echo "train folder not found"
    exit 1
fi

function check_label_name()
{
    xml="${1}"
    atleastone=0

    while IFS= read -r label
    do
	if [[ "${label}" != "hornet" ]] && [[ "${label}" != "bee" ]]
	then
	    echo "WARNING: file ${xml} has an unknown label: ${label}"
	fi
	atleastone=1
    done < <(grep -o "<name>.*</name>" "$xml" | sed 's,^<name>,,g' | sed 's,</name>$,,g')

    # if [[ ${atleastone} == 0 ]]
    # then
    # 	echo "WARNING: file ${xml} has no labels"
    # fi
}

function check_xml()
{
    name="${1}"
    if ! [ -f ${name%.*}.xml ]
    then
	echo "WARNING: file ${name} does not have corresponding XML file"
	return 1
    fi

    check_label_name "${name%.*}.xml"
}

test="${folder}/test"
train="${folder}/train"

nb_test=$(ls -1 ${test}/*.xml | wc -l)
nb_train=$(ls -1 ${train}/*.xml | wc -l)

printf "NB TEST: %d (%d)  TRAIN: %d (%d) TOTAL: %d\n" $nb_test $(echo "100*$nb_test/($nb_test+$nb_train)" | bc) $nb_train  $(echo "100*$nb_train/($nb_test+$nb_train)" | bc) $(($nb_test+$nb_train))


for file in ${test}/* ; do
    if [[ $file =~ \.xml$ ]] ; then continue ; fi

    check_xml "${file}"
done

for file in ${train}/* ; do
    if [[ $file =~ \.xml$ ]] ; then continue ; fi

    check_xml "${file}"
done
