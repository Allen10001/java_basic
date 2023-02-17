#!/usr/bin/env bash

commit_msg=$1

base_path=$(cd $(dirname $0);pwd)

for file in ./*
do
	cd $base_path
    if test -d $file
    then
    	cd $file
        if test -d ".git"
        then
        	git add -A
        	git commit -m $commit_msg
        	git push origin master
    		echo update $base_path${file:1} success!
        fi	
    fi
done