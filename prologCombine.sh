#!/bin/sh
clear

exportName="combine.pl"

echo "Combining all prolog files into one file: $exportName"
if test ! -e $exportName; then
    touch $exportName
fi

echo "" > $exportName

for file in *.pl; do
    if test ! "$file" = "$exportName";then
        cat $file >> $exportName
    fi 
done

swipl combine.pl