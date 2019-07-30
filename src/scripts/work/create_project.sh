#!/bin/zsh

if [ $# -ne 1 ]
then
    echo "$0 <project root directory>"
    exit -1
fi

ROOT_DIR=$1


# Generate directories
mkdir -p $ROOT_DIR/administrative
mkdir -p $ROOT_DIR/bibliography
mkdir -p $ROOT_DIR/expes
mkdir -p $ROOT_DIR/meetings
mkdir -p $ROOT_DIR/presentations
mkdir -p $ROOT_DIR/publications
mkdir -p $ROOT_DIR/tools

# Generate bibliography specificities
mkdir -p $ROOT_DIR/bibliography/pdfs
cat <<EOT >> $ROOT_DIR/bibliography/index.org
#+TITLE: Bibliography entry point
#+AUTHOR:
#+EMAIL: lemagues@tcd.ie
#+DATE: 14 January 2019
#+DESCRIPTION:
#+KEYWORDS:
#+LANGUAGE:  fr
#+OPTIONS:   H:3 num:t toc:t \n:nil @:t ::t |:t ^:t -:t f:t *:t <:t
#+SELECT_TAGS: export
#+EXCLUDE_TAGS: noexport
#+HTML_HEAD: <link rel="stylesheet" type="text/css" href="https://seblemaguer.github.io/css/default.css" />
#+HTML_HEAD: <link rel="stylesheet" type="text/css" href="default.css" />
#+CATEGORY: Bibliography

* COMMENT some extra configuration
EOT

# Generate some helper files
cat <<EOT >> $ROOT_DIR/index.org
#+TITLE: Notes and helpers
#+AUTHOR: Sébastien Le Maguer
#+EMAIL: lemagues@tcd.ie
#+DATE:
#+DESCRIPTION:
#+KEYWORDS:
#+LANGUAGE:  fr
#+OPTIONS:   H:3 num:t toc:t \n:nil @:t ::t |:t ^:t -:t f:t *:t <:t
#+SELECT_TAGS: export
#+EXCLUDE_TAGS: noexport
#+HTML_HEAD: <link rel="stylesheet" type="text/css" href="https://seblemaguer.github.io/css/default.css" />
#+HTML_HEAD: <link rel="stylesheet" type="text/css" href="default.css" />

* COMMENT some extra configuration
EOT
