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
            git fetch origin master
            git rebase origin/master
        	echo rebase $base_path${file:1} success!
        fi	
    fi
done