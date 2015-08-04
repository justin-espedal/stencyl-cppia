mkdir ..\export
haxe compile-stencyl-cppia-host.hxml
call build-stencyl-cppia-host.bat
cd %~dp0
call export-sources.bat