#!/usr/bin/env bash
export CL_RED="\"\033[31m\""
export CL_GRN="\"\033[32m\""
export CL_YLW="\"\033[33m\""
export CL_BLU="\"\033[34m\""
export CL_MAG="\"\033[35m\""
export CL_CYN="\"\033[36m\""
export CL_RST="\"\033[0m\""
export BUILD_WITH_COLORS=0
 
git config --global user.name "$username"
git config --global user.email "$useremail"

mkdir -p ~/bin
export PATH=~/bin:$PATH
curl https://dl-ssl.google.com/dl/googlesource/git-repo/repo > ~/bin/repo
chmod a+x ~/bin/repo

export USE_CCACHE=$uccache
if [["$uccache" = "1"]]
then
export CCACHE_NLEVELS=4
export BUILD_WITH_COLORS=0
# make sure ccache is in PATH
if [[ "$REPO_BRANCH" =~ "jellybean" || "$REPO_BRANCH" =~ "cm-10" || "$REPO_BRANCH" =~ "cm-10.1" || "$REPO_BRANCH" =~ "cm-10.2" || "$REPO_BRANCH" =~ "cm-10.3"]]
then
export PATH="$PATH:/opt/local/bin/:$PWD/prebuilts/misc/$(uname|awk '{print tolower($0)}')-x86/ccache"
export CCACHE_DIR=~/.jb_ccache
else
export PATH="$PATH:/opt/local/bin/:$PWD/prebuilt/$(uname|awk '{print tolower($0)}')-x86/ccache"
export CCACHE_DIR=~/.ics_ccache
fi
if [ ! "$(ccache -s|grep -E 'max cache size'|awk '{print $4}')" = "40.0" ]
then
  ccache -M 40G
fi
fi

if [[ "$git_reset" =~ "y" ]]
then
echo cleaning repo...
repo forall -c "git reset --hard"
fi

repo init -u $initurl -b $branch
if [ ! -z "$manifest" ]; then
  curl $manifest > ./.repo/local_manifest.xml
fi

repo sync $syncargs $joblvl
check_result "repo sync failed."

. build/envsetup.sh
lunch $LUNCH
make $joblvl $makeargs

cp -rf $OUT/cm-*.zip* $WORKSPACE/archive
