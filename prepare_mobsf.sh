#!/bin/bash

# Read parameters.
PROJECT_NAME=$1
FROM_BRANCH=$2 # $BITRISE_GIT_BRANCH - this is branch existing in Bitrise
TO_BRANCH=$3   # $BITRISEIO_GIT_BRANCH_DEST - this is branch existing in Bitrise

# Zip functions

function zip_project() {
    echo -e "Run zip whole"
    # Copy xcodeproj to RootDirectory
    xcproj_file=$(find . -name "${PROJECT_NAME}.xcodeproj")
    cp -r $xcproj_file ./

    # Create zip
    zip -r mobsf_files.zip .
}

function zip_diff_files() {
    echo -e "Run zip diff"
    # Copy diff files to mobsf_files directory.
    DIFF_FILES="$(git diff --name-only $TO_BRANCH..$FROM_BRANCH)"
    FILES_ARRAY=($(echo $DIFF_FILES | tr " " "\n"))
    mkdir mobsf_files
    cp ${FILES_ARRAY[@]} ./mobsf_files

    # Copy xcodeproj.
    xcproj_file=$(find . -name "${PROJECT_NAME}.xcodeproj")
    cp -r $xcproj_file ./mobsf_files

    # Copy Info.plist.
    plists="$(find . -name 'Info.plist')"
    cp $plists ./mobsf_files

    # Create zip.
    cd ./mobsf_files
    zip -r mobsf_files.zip .
    cd ..
    cp ./mobsf_files/mobsf_files.zip ./mobsf_files.zip

    # Remove previously created files.
    rm -rf ./mobsf_files
}

# Program execution

# Remove previously created files.
rm -rf ./mobsf_files

if [ -n "$FROM_BRANCH" ] && [ -n "$TO_BRANCH" ]; then
    zip_diff_files
else
    zip_project
fi
