#!/bin/sh
# Hace pruebas, pruebas de regresión, envia a github y sube a heroku

grep "^ *gem *.sivel2_gen. *, *path:" Gemfile > /dev/null 2> /dev/null
if (test "$?" = "0") then {
	echo "Gemfile inlcuye un sivel2_gen cableado al sistema de archivos"
	exit 1;
} fi;

rspec
if (test "$?" = "0") then {
	b=`git branch | grep "^*" | sed -e  "s/^* //g"`
	git status -s
	git commit -a
	git push origin ${b}
	if (test "$?" = "0") then {
		git push heroku master
	} fi;
} fi;

