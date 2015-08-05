#!/bin/sh

mkdir ../bin
mkdir ../bin/linux64
mkdir ../export
mkdir ../export/scripts

cd hxml
haxe compile-linux64.hxml
cd ..

cp src/DefaultAssetLibrary.hx ../export
cp src/scripts/MyAssets.hx ../export/scripts
cp src/scripts/MyScripts.hx ../export/scripts

cp temp/linux64/StencylCppia ../bin/linux64