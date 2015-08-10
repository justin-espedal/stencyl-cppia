# stencyl-cppia
Cppia host for Stencyl games

### Initial References

Based primarily on [acadnme](https://github.com/nmehost/acadnme).

Some example hxml files in the Haxe [unit tests](https://github.com/HaxeFoundation/haxe/tree/development/tests/unit), and part of an [hxml overview](http://matttuttle.com/2015/06/hxml-overview/) by Matt Tuttle.

### Building From Source

This folder is assumed to be installed as a haxelib at Stencyl/plaf/haxe/lib, and the stencyl engine should be generated there too.

Use `tools/run/compile.hxml` to generate the haxelib's `run.n` script, which is used as a lime target handler for `cppia`, and also to generate the host.

After compiling run.n, from a stencyl workspace, run the command "haxelib run stencyl-cppia dist-setup" to generate files within the stencyl-cppia folder to prepare it for Stencyl users.

To manually generate the host executable, you can run "haxelib run stencyl-cppia setup" from the stencyl workspace, but it can also be automatically generated by testing a game in Stencyl.

If the host executable is run standalone, it will display a list of cppia games that have been generated (this assumes the host to be generated in the stencyl workspace).

### Used as a Stencyl Target

To enable cppia in Stencyl, set `cppia.enabled=true` in `prefs/boot.txt`. Then export a game with the `cppia` target.
