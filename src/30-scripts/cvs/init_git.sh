#!/bin/zsh

if [ $# -ne 1 ]
then
    echo "$0 <repo_origin address>"
    exit -1
fi

git remote add origin $1
git push -u origin --all # pushes up the repo and its refs for the first time
git push -u origin --tags # pushes up any tags
