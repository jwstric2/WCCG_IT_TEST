#!/bin/bash

set -e

########################################################################
#################### Push Local Changes to Git  ########################
########################################################################
# Description:
# This script pushes local changes to git as a backup
usage ()
{
cat <<- _EOF_

#########################################################################################
 Options:
 -h or --help              Display the HELP message and exit.
 --dest_dir                (Required)The relative local destination directory of the
                           cloned directory
 --git_url                 (Required) The git url.  It is recommeded to give a
													 ssh url with a user that has the correct identify information
													 for pushing
 --src_dir                 (Required) The src data directory to backup


 Example:
   ./pushLocalChangesToGit.sh --src_dir=/home/user/files --dest_dir=files \
	                            --git_url=https://github.com/myorg/myrepo
_EOF_
}

validate_vars() {
  VARS=('src_dir' 'dest_dir')
  for var in "${VARS[@]}"
  do
    if  [ -z  "${!var}"  ]; then
      echo "MISSING ${var}."
      exit 1
    fi
  done
}

function banner()
{
	echo
	echo "-----------------------------------"
	echo $*
	echo "-----------------------------------"
}

function catch_errors() {
  echo "script aborted, because of errors on line $1"
  exit 1
}

# Generates a temporary location directory and clones the given repository
function clone_repository()
{
    local temp_dir=$(mktemp -d /tmp/gitclone.XXXXXXXXX)
		git clone ${git_url} ${temp_dir}
    echo "${temp_dir}"
}

# this will trap any errors or commands with non-zero exit status
# by calling function catch_errors()
trap 'catch_errors $LINENO' ERR;

src_dir=""
dest_dir=""
git_url=""

for i in "$@"
do
  case $i in
		--dest_dir=*)
      dest_dir="${i#*=}"
      shift
		;;
		--git_url=*)
      git_url="${i#*=}"
      shift
		;;
		--src_dir=*)
      src_dir="${i#*=}"
      shift
    ;;
    -h | --help)
      usage
      exit
    ;;
    *)
      echo "Unknown option: $i"
      exit 1
    ;;
  esac
done

# Validate all required vars were given
validate_vars

clone_dir=$(clone_repository)
cd "${clone_dir}"

banner "Refreshing local repository"
git pull

banner "Detecting and copying changes"
cp -vpur "${src_dir}"/* "${dest_dir}"

#
# Detect new files, commits
#
banner "Checking for new files or missing commits"
if [ -z "$(git status --porcelain)" ]; then
  echo "No new files to track"
else
	banner "Add new content to the index..."
	git add .

	banner "Committing new changes..."
	DATE=`date '+%Y%m%d%H%M%S'`
	COMMITMSG="Commit date is $DATE"
	git commit -m "$COMMITMSG" -a
fi

banner "Pushing..."
git push

banner "Last few commits"
git log -n 3
