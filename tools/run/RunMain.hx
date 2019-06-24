package;

import haxe.Unserializer;
import hxp.*;
import sys.*;
import sys.io.*;

import lime.tools.*;
import lime.project.*;
//import lime.utils.Log;

using Lambda;
using StringTools;

class RunMain
{
	public static function main()
	{
		//build, run, test: test game
		
		var arguments = Sys.args();

		trace(Sys.args());

		//XXX: https://github.com/HaxeFoundation/haxe/issues/5708
		var thisPath = Sys.executablePath();

		var libraryFolder = Path.standardize(thisPath.substring(0, thisPath.indexOf("run.exe")), false);
		var cppiaFolder = libraryFolder.substring(0, libraryFolder.lastIndexOf("/lib"));
		
		trace('cppiaFolder: $cppiaFolder');

		var command = arguments[0];
		
		//All generated binaries go into Stencyl Workspace

		var debug = arguments.indexOf("-debug") != -1;

		//Platform info

		var platform = System.hostPlatform;
		var is64 = System.hostArchitecture == HostArchitecture.X64;

		if(platform == HostPlatform.WINDOWS)
			is64 = false;

		var basePlatformID = platform + (is64  ? "64" : "");
		var platformID = basePlatformID + (debug ? "-debug" : "");

		//Binary locations

		var binFolder = '$cppiaFolder/bin/$platformID';
		FileSystem.createDirectory(binFolder);

		var binSuffix = (platform == HostPlatform.WINDOWS ? ".exe" : "");
		var debugSuffix = debug ? "-debug" : "";
		var hasBin = FileSystem.exists('$binFolder/StencylCppia$binSuffix');

		CppiaPlatform.hostExecutablePath = '$binFolder/StencylCppia$binSuffix';

		if(!hasBin)
		{
			trace("Missing host. Rebuild cppia first.");
			return;
		}
		
		if(command == "test" || command == "build" || command == "run")
		{
			var argsIndex = arguments.indexOf("-args");
			var genIndex = arguments.indexOf("-gen");
			var openflIndex = arguments.indexOf("-openfl");

			var additionalArgs = arguments.slice(argsIndex + 1, genIndex);
			var openflProjectPath = arguments[genIndex + 1].urlDecode();
			var openflArgs = arguments.slice(openflIndex + 1);

			CppiaPlatform.projectPath = openflProjectPath;

			// ---

			var serializedProjectPath = arguments[1];

			try { Sys.setCwd (openflProjectPath); } catch (e:Dynamic) {}
			trace("Cwd: " + Sys.getCwd());

			var project:HXProject = Unserializer.run(File.getContent(serializedProjectPath));
			project.templatePaths = project.templatePaths.concat ([ Path.combine (libraryFolder, "templates") ]);

			var builder = new CppiaPlatform(command, project, project.targetFlags);
			builder.execute(additionalArgs);
		}
	}
}
