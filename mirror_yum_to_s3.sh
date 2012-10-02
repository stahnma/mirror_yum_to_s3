#!/bin/bash

# This is a very simple script to mirror a yum repository to s3 and then make
# that repository publicly accesable.

# Your yum clients should have something like this for their setups:

# /etc/yum.repos.d/BUCKET_NAME.repo
#[BUCKET_NAME]
#name=BUCKET_NAME-$releasever
#baseurl=http://BUCKET_NAME.s3.amazonaws.com/rpms
#gpgcheck=0

# This script assumes you have s3cmd installed and configured.

# Layout:
#  $0 is in a directory
#  Subdirectory called rpms

#  You provide a BUCKET_NAME on the CLI
BUCKET_NAME=$1
if [ -z "${BUCKET_NAME}" ] ; then
    echo "Usage: $0 BUCKET_NAME"
    exit 1
fi


s3cmd mb s3://${BUCKET_NAME} &> /dev/null

# Call createrepo with optimium flags for short running processes
createrepo -d --update   -C --changelog-limit  5 rpms

s3cmd sync rpms s3://${BUCKET_NAME} && \
    s3cmd setacl -P s3://${BUCKET_NAME}/rpms/* s3://${BUCKET_NAME}/rpms/repodata/*
