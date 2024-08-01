#!/bin/bash

# Read the current version from the file
version=$(cat version.txt)

# Split the version into an array by the dot delimiter
IFS='.' read -r -a version_parts <<< "$version"

# Increment the patch version (the last element of the array)
((version_parts[2]++))

# Reassemble the version parts into the new version string
new_version="${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"

# Write the new version back to the file
echo "$new_version" > version.txt

# Print the new version to the console (optional)
echo "Updated version: $new_version"