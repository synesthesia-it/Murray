#!/bin/sh
#
#
REPONAME="Murray"

function installTemplates {

	cd $REPONAME
	swift build -c release
	cp -f .build/release/Murray /usr/local/bin/murray
	cd ..
	rm -rf $REPONAME
	echo "Boomerang templates installed"
}

cd /tmp/
rm -rf $REPONAME
git clone https://github.com/synesthesia-it/Murray.git && installTemplates
