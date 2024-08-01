#!/bin/bash

# Read the version from the file
version=$(cat version.txt)

# Create a Git tag
git tag -a "v$version" -m "Release version $version"

# Push the tag to the remote repository
git push origin "v$version"