#!/bin/bash

# Dropbox ID Generator

# REQUIRES THE FOLLOWING IN THE script DIRECTORY
#..
#├── script/
#|   ├── db_token.var
#|   ├── repo.var
#│   ├── create-db-shared-link.php
#│   └── db-id-gen.sh
#

# Example input
# - ./db-id-gen.sh '/path/to/music/file/techno.mp3' 'techno.mp3' github

# This script is designed to upload music to dropbox, get the link and update webpage
# The script uploads an mp3 to dropbox and gets its shared link into a variable
# Then generates a .md page wth liquid tags for a jekyll webserver into the webs git repository
# Then jekyll sees the repository update and regenerates the website
# The jekyll site generator parses the liquid tags and runs an include
# The include embeds the audio file onto the webpage 

# The end result is a simple command to add MP3's to an html5 audio player and have the src streamed from dropbox

# Next updates will do all this and automatically push the git repository when a file is detected in a specific directory on a NAS.



export localfile="$1"
export remotefile="$2"
export output="$3"   #(term | github)
export db_auth="$(cat ./db_token.var)"
export gitrepo="$(cat ./repo.var)"

# - - - - - -

#Dropbox Check if File on Server
db_check_server() {
curl -X POST https://api.dropboxapi.com/2/files/list_folder \
--header "Authorization: Bearer $db_auth" \
--header 'Content-Type: application/json' \
--data '{"path":""}' 2> /dev/null | python -mjson.tool | grep -qi "$remotefile"

fileexists="$?"

# (Exit of 0 = File On Server)
# (Exit of non-zero = File Does Not Exist )
}

# - - - - - -

# Dropbox File Uploader
db_upload_file() {
curl -X POST https://content.dropboxapi.com/2/files/upload \
--header "Authorization: Bearer $db_auth" \
--header "Dropbox-API-Arg: {\"path\": \"/$remotefile\",\"mode\": \"add\",\"autorename\": true,\"mute\": false}" \
--header "Content-Type: application/octet-stream" \
--data-binary @"$localfile" &> /dev/null #|
#tee /dev/tty |
#python -mjson.tool
}

# - - - - - -

# Create Shared Dropbox Link.
db_crt_shrd_lnk() {
json_url=$( ./create-db-shared-link.php "$remotefile" 2> /dev/null | python -mjson.tool | grep '"url":' )
db_loc_half=${json_url#*: }
db_id_halfway=${json_url#*www.dropbox.com/s/}
db_loc=${db_loc_half//\"}
db_id=${db_id_halfway%\?*}
}

# - - - - - -

#Push changes to git repository
push_to_github() {
pushd .. &> /dev/null
git add "_music/$remotefile.md"
git commit -m "New File"
git pull --commit
git push
popd &> /dev/null
}

# - - - - - - 

db_check_server

if [[ "$fileexists" == "0" ]];then
  echo "File $remotefile exists on server already."
  db_crt_shrd_lnk
  if [ "$output" = "term" ];then
    echo "$db_loc"
    echo "$db_id"
  fi
else
  db_upload_file
  sleep 5
  db_crt_shrd_lnk
  if [ "$output" = "term" ];then
    echo "$db_loc"
    echo "$db_id"
  fi
fi

if [ "$output" = "github" ];then
  pushd .. &> /dev/null
  if [[ $(pwd | grep -i "$gitrepo") == *"$gitrepo" ]];then
    if ! [ -e "./_music/$remotefile.md" ];then
      echo "---" > "./_music/$remotefile.md"
          echo "title: $remotefile" >> "./_music/$remotefile.md"
          echo "music_loc: $db_loc" >> "./_music/$remotefile.md"
          echo "dropbox_id: $db_id" >> "./_music/$remotefile.md"
          echo "---" >> "./_music/$remotefile.md"
          popd &> /dev/null
        else
          echo "File ./_music/$remotefile exists in repository already."
        fi
  else
    echo "Bad Directory need to be in root of git repository."
        exit 1
  fi
fi

echo "Finished."
