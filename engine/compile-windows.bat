mkdir ..\bin
mkdir ..\bin\windows
mkdir ..\export
mkdir ..\export\scripts

cd hxml
haxe compile-windows.hxml
cd ..

copy src\DefaultAssetLibrary.hx ..\export
copy src\scripts\MyAssets.hx ..\export\scripts
copy src\scripts\MyScripts.hx ..\export\scripts

copy temp\windows\StencylCppia.exe ..\bin\windows