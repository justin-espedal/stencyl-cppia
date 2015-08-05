mkdir ..\bin
mkdir ..\bin\windows64
mkdir ..\export
mkdir ..\export\scripts

cd hxml
haxe compile-windows64.hxml
cd ..

copy src\DefaultAssetLibrary.hx ..\export
copy src\scripts\MyAssets.hx ..\export\scripts
copy src\scripts\MyScripts.hx ..\export\scripts

copy temp\windows64\StencylCppia.exe ..\bin\windows64