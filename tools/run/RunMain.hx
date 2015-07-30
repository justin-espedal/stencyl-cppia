package;

import haxe.Unserializer;
import sys.*;
import sys.io.*;

import lime.tools.helpers.*;
import lime.project.*;

using Lambda;
using StringTools;

class RunMain
{
	public static function main()
	{
		var arguments = Sys.args();
		
		if(arguments.length < 2)
		{
			trace("Not enough arguments");
			
			return;
		}
		
		var command = arguments[0];
		var projectPath = arguments[1];
		
		var i = 2;
		while(arguments[i] != "-args") ++i;
		var gamePath = arguments[i + 1].urlDecode();
		try { Sys.setCwd (gamePath); } catch (e:Dynamic) {}
		trace("Cwd: " + Sys.getCwd());
		
		var project:HXProject = Unserializer.run(File.getContent(projectPath));
		project.templatePaths = [ PathHelper.combine (PathHelper.getHaxelib (new Haxelib ("stencyl-cppia")), "templates") ].concat (project.templatePaths);
		
		var platform = new CppiaPlatform(command, project, project.targetFlags);
		platform.execute([]);
	}
}