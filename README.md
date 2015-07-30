# stencyl-cppia
Cppia host for Stencyl games

Based primarily on [acadnme](https://github.com/nmehost/acadnme).

Some example hxml files in the Haxe [unit tests](https://github.com/HaxeFoundation/haxe/tree/development/tests/unit), and part of an [hxml overview](http://matttuttle.com/2015/06/hxml-overview/) by Matt Tuttle.

Right now there are a few .bat files being used that will need to be replaced before everything can be built off of Windows.

This folder is assumed to be placed in Stencyl/plaf/haxe/lib, and the stencyl engine should be generated there too.

`tools/list-classes/compile.hxml` to scan `[Stencyl]/plaf/haxe/lib/stencyl` for source files and add them to a list of imports to keep, located at `engine/src/AllStencyl.hx`.

`engine/compile-stencyl-cppia-host.hxml` to pull all of the libraries we use (openfl, lime, hxcpp, actuate, console, polygonal-ds, polygonal-printf, box2d, stencyl) and compile them into an executable in `engine/temp/windows/haxe/cpp`. It also generates a list of classes under `export` which are used to keep client scripts from compiling more than they need to.

`tools/run/compile.hxml` to generate the haxelib's `run.n` script, which is used as a lime target handler for `cppia`.

In Stencyl, export a game with the `cppia` target. Use the following in the `openfl settings` field of the advanced project settings.

```
<section if="cppia">
	
	<target name="cppia" handler="stencyl-cppia" />
	<haxelib name="stencyl-cppia" />
	
</section>
```
