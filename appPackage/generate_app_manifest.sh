#!/usr/bin/env bash
# Package the app manifest and the icons in a zip file that can be deployed or sideloaded as an App
# in MS Teams. This is the same zip file that App Studio produce.

# manifest_TEMPLATE.json      : The manifest for a specific environment (local, dev, stage, prod)
# color.png          : The icon to display in the product page listing in the Teams gallerpac
#                      This is the full-color product logo.
# outline.png        : The icon to display in Teams, in the Teams chat channel and other locations.
#                      This is your logo rendered as a white outline with transparent background.
# appId_targetEnv    : Unique UUID for each environment (you can use https://www.uuidgenerator.net/ or any tool like Visual Studio to generate this.)
# botId_targetEnv    : Application (client) ID from Azure App registrations Portal while creating Microsoft App ID and password for the Bot for target environment.
# botName_targetEnv  : Should be same as Display name of the Bot registered on https://dev.botframework.com/bots
# domain_targetEnv   : Teams Tab frontend DOMAIN URL.

targetEnv=("dev" "stage" "prod" "local");

appId_prod=""
botId_prod=""
botName_prod=""
appversion_prod="1.0.0"

appId_stage=""
botId_stage=""
botName_stage=""
appversion_stage="1.0.0"

appId_dev=""
botId_dev=""
botName_dev=""
appversion_dev="1.0.0"

appId_local=""
botId_local=""
botName_local="My First Bot"
appversion_local="1.0.0"

generate_manifest () {
  local env=$1
  capitalizedEnv=$(echo "$env" | tr [a-z] [A-Z])
  appId="appId_$env"
  botId="botId_$env"
  botName="botName_$env"
  appversion="appversion_$env"

  if [[ -d "$env" ]]; 
  then
    rm -rf $env
    echo "Removed previously generated $env"
    mkdir "$env" 
  fi

  if [[ -f "App_"$env".zip" ]]; 
  then
    echo "Removed previously generated App_$env.zip"
    rm -rf App_"$env".zip
  fi

  rsync -auv languages/ "$env"/
  find "$env" -type f -name "*.json" -exec sed -i '' "s/\[BOT_NAME\]/${!botName}/g" {} +
  if [[ 'prod' =~ $env ]];
  then
    sed -e "s/\[TEAMS_APP_ID\]/${!appId}/;s/\[BOT_ID\]/${!botId}/;s/\[APP_VERSION\]/${!appversion}/;s/\[BOT_NAME\]/${!botName}/" \
    -e "s/\[ENV\]//" -e "/ngrok/d"\
    manifest_TEMPLATE.json > "$env"/manifest.json
  else
    sed -e "s/\[TEAMS_APP_ID\]/${!appId}/;s/\[BOT_ID\]/${!botId}/;s/\[APP_VERSION\]/${!appversion}/;s/\[BOT_NAME\]/${!botName}/" \
    -e "s/\[ENV\]/$(printf "%s%s" ' ' "$capitalizedEnv")/" \
    manifest_TEMPLATE.json > "$env"/manifest.json
  fi
  zip -j App_"$env".zip "$env"/* icons/*;
  rm -rf $env
  echo "Created the file App_$env.zip"
}

if [[ ${targetEnv[*]} =~ $1  ]];
then
  generate_manifest "$1"
elif [[ 'all' =~ $1 ]];
then
  echo "Regenerating all manifest files"
  for env in "${targetEnv[@]}"
  do
    generate_manifest "$env"
  done
else
  echo "Please specify the environment: dev, stage, prod or local or all";
fi
