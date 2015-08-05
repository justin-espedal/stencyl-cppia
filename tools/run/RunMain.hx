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
		
		var argsIndex = arguments.indexOf("-args");
		var genIndex = arguments.indexOf("-gen");
		var openflIndex = arguments.indexOf("-openfl");
		
		var additionalArgs = arguments.slice(argsIndex + 1, genIndex);
		var openflProjectPath = arguments[genIndex + 1].urlDecode();
		var openflArgs = arguments.slice(openflIndex + 1);
		
		// ---

		var command = arguments[0];
		var serializedProjectPath = arguments[1];
		
		try { Sys.setCwd (openflProjectPath); } catch (e:Dynamic) {}
		trace("Cwd: " + Sys.getCwd());

		var project:HXProject = Unserializer.run(File.getContent(serializedProjectPath));
		project.templatePaths = [ PathHelper.combine (PathHelper.getHaxelib (new Haxelib ("stencyl-cppia")), "templates") ].concat (project.templatePaths);
		
		var platform = new CppiaPlatform(command, project, project.targetFlags);
		platform.execute(additionalArgs);
	}
}