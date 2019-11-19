#!/bin/bash

REPO="$HOME/gitrepos/mixers"
SRCDATA=$HOME/Documents/PreSonus/StudioLive\ AI/Library/Presets
TRGDATA="$REPO/MixerPC"

function banner()
{
	echo
	echo "-----------------------------------"
	echo $*
	echo "-----------------------------------"
}

echo "SOURCE: $SRCDATA"
echo "TARGET: $TRGDATA"

banner "Detecting and copying changes"
cp -vpur "$SRCDATA"/* "$TRGDATA"

cd $TRGDATA
