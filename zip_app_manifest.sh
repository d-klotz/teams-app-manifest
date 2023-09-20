#!/usr/bin/env bash
# Package the app manifest and the icons in a zip file that can be deployed or sideloaded as an App
# in MS Teams. This is the same zip file that App Studio produce.

# manifest.json : The manifest for a specific environment (local, dev, stage, prod)
# color.png     : The icon to display in the product page listing in the Teams gallerpac
#                 This is the full-color product logo.
# outline.png   : The icon to display in Teams, in the Teams chat channel and other locations.
#                 This is your logo rendered as a white outline with transparent background.
targetEnv=("dev" "stage" "prod" "local");

if [[ ${targetEnv[*]} =~ $1  ]];
then
    zip -j App_$1.zip $1/manifest.json icons/*;
    echo "Created the file App_$1.zip"
else
    echo "Please specify the environment: dev, stage, prod or local";
fi
