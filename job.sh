#!/usr/bin/env bash
export CL_RED="\"\033[31m\""
export CL_GRN="\"\033[32m\""
export CL_YLW="\"\033[33m\""
export CL_BLU="\"\033[34m\""
export CL_MAG="\"\033[35m\""
export CL_CYN="\"\033[36m\""
export CL_RST="\"\033[0m\""
export BUILD_WITH_COLORS=0
 
git config --global user.name 'name'
git config --global user.email 'name@server.tld'
mkdir -p ~/bin
export PATH=~/bin:$PATH
curl https://dl-ssl.google.com/dl/googlesource/git-repo/repo > ~/bin/repo
chmod a+x ~/bin/repo
repo init -u $initurl -b $branch
if [ ! -z "$manifest" ]; then
  curl $manifest > ./.repo/local_manifest.xml
fi
repo sync $syncargs $joblvl
. build/envsetup.sh
lunch $LUNCH
make $joblvl $makeargs
cp $OUT/*.* $WORKSPACE/archive
