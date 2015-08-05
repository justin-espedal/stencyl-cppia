# stencyl-cppia
Cppia host for Stencyl games

### Initial References

Based primarily on [acadnme](https://github.com/nmehost/acadnme).

Some example hxml files in the Haxe [unit tests](https://github.com/HaxeFoundation/haxe/tree/development/tests/unit), and part of an [hxml overview](http://matttuttle.com/2015/06/hxml-overview/) by Matt Tuttle.

### Building From Source

This folder is assumed to be placed in Stencyl/plaf/haxe/lib, and the stencyl engine should be generated there too.

Use `tools/list-classes/compile.hxml` to scan `[Stencyl]/plaf/haxe/lib/stencyl` for source files and add them to a list of imports to keep, located at `engine/src/AllStencyl.hx`.

Use `engine/compile-{platform}` to pull all of the libraries we use (openfl, lime, hxcpp, actuate, console, polygonal-ds, polygonal-printf, box2d, stencyl) and compile them into an executable in `bin/{platform}`. It also generates a list of classes under `export` which are used to keep client scripts from compiling more than they need to.

At this point, it's possible to run the generated `bin/{platform}/StencylCppia`. The path or working directory must contain lime-legacy.ndll. It will print a message asking you to run the executable with a .cppia file as an argument. We can generate .cppia files by compiling games in stencyl using the cppia target and having the target handled by stencyl-cppia.

Use `tools/run/compile.hxml` to generate the haxelib's `run.n` script, which is used as a lime target handler for `cppia`.

### Used as a Stencyl Target

To enable cppia in Stencyl, set `cppia.enabled=true` in `prefs/boot.txt`. Then export a game with the `cppia` target and it will run automatically.
