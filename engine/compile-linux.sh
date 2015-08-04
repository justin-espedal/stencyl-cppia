#!/bin/sh

mkdir ../bin
mkdir ../bin/linux
mkdir ../export
mkdir ../export/scripts

cd hxml
haxe compile-linux.hxml
cd ..

cp src/DefaultAssetLibrary.hx ../export
cp src/scripts/MyAssets.hx ../export/scripts
cp src/scripts/MyScripts.hx ../export/scripts

cp temp/linux/StencylCppia ../bin/linux