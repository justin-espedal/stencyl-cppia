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
		//setup: compile host
		
		var arguments = Sys.args();

		trace(Sys.args());

		//XXX: https://github.com/HaxeFoundation/haxe/issues/5708
		var thisPath = Sys.executablePath();

		var libraryFolder = Path.standardize(thisPath.substring(0, thisPath.indexOf("run.exe")), false);
		var cppiaFolder = libraryFolder.substring(0, libraryFolder.lastIndexOf("/lib"));
		
		trace('cppiaFolder: $cppiaFolder');

		var command = arguments[0];

		var hostSetup = command == "setup";

		//All generated binaries go into Stencyl Workspace

		var stencylFolder =
			if(arguments.indexOf("-stencyl-folder") != -1)
				arguments[arguments.indexOf("-stencyl-folder") + 1]
			else
				null;

		var debug = arguments.indexOf("-debug") != -1;

		if(hostSetup && stencylFolder == null)
		{
			trace("Must pass -stencyl-folder path/to/stencyl to run setup");
			return;
		}

		//Platform info

		var platform = System.hostPlatform;
		var is64 = System.hostArchitecture == HostArchitecture.X64;

		if(platform == HostPlatform.WINDOWS)
			is64 = false;

		var basePlatformID = platform + (is64  ? "64" : "");
		var platformID = basePlatformID + (debug ? "-debug" : "");

		var architectureString = (is64 ? "64" : "32");
		var platformType = "desktop";

		//Binary locations

		var binFolder = '$cppiaFolder/bin/$platformID';
		FileSystem.createDirectory(binFolder);

		var binSuffix = (platform == HostPlatform.WINDOWS ? ".exe" : "");
		var debugSuffix = debug ? "-debug" : "";
		var hasBin = FileSystem.exists('$binFolder/StencylCppia$binSuffix');

		CppiaPlatform.hostExecutablePath = '$binFolder/StencylCppia$binSuffix';

		//Setup

		hostSetup = hostSetup || !hasBin;

		if(hostSetup)
		{
			var stencylClassList = ListClasses.list("stencyl", "AllStencyl", ["com"], ListClasses.include, ListClasses.exclude);
			File.saveContent('$libraryFolder/engine/src/AllStencyl.hx', stencylClassList);
			
			var tempFolder = '$cppiaFolder/temp/$platformID';
			FileSystem.createDirectory(tempFolder);

			var haxeArgs =
			[
				'compile-common.hxml',

				'-D', 'HXCPP_M$architectureString',
				'-D', '$platform',
				'-D', '$platformType',

				'-cp', '$stencylFolder/plaf/haxe/extensions/gestures',

				'-cpp', '$tempFolder'
			];			
			if(debug)
			{
				haxeArgs = haxeArgs.concat([
					'-D', 'HXCPP_DEBUGGER',
					'-D', 'openfl-debug',
					'-D', 'lime-debug',
					'-debug',
					'-D', 'HXCPP_STACK_TRACE',
				]);
			}
			
			var originalHaxeArgs = haxeArgs;

			var exportFolder = '$libraryFolder/export';
			FileSystem.createDirectory(exportFolder);

			haxeArgs = haxeArgs.concat([
				'-D', 'dll_export=$exportFolder/export_classes.info',
				'-D', 'no-compilation'
			]);
			
			try { Sys.setCwd ('$libraryFolder/engine/hxml'); } catch (e:Dynamic) {}
			trace("haxe " + haxeArgs);
			System.runCommand ("", "haxe", haxeArgs);
			trace("haxe " + originalHaxeArgs);
			System.runCommand ("", "haxe", originalHaxeArgs);
			
			var srcFolder = '$libraryFolder/engine/src';
			export('$exportFolder/export_classes.info', "^(class|enum|interface)");
			FileSystem.createDirectory('$exportFolder/scripts');
			System.copyIfNewer('$srcFolder/ManifestResources.hx', '$exportFolder/ManifestResources.hx');
			System.copyIfNewer('$srcFolder/scripts/MyScripts.hx', '$exportFolder/scripts/MyScripts.hx');
			System.copyIfNewer('$srcFolder/StencylCppiaScript.hx', '$exportFolder/StencylCppia.hx');
			
			var tempBinPath = '$tempFolder/StencylCppia$debugSuffix$binSuffix';
			var binPath = '$binFolder/StencylCppia$binSuffix';

			var limeFolder = Path.standardize(Haxelib.getPath (new Haxelib ("lime")), false);
			platformID = basePlatformID.substr(0, 1).toUpperCase() + basePlatformID.substr(1);
			var ndllPath = '$limeFolder/ndll/$platformID/lime.ndll';
			var ndllDestPath = '$binFolder/lime.ndll';

			System.copyIfNewer(tempBinPath, binPath);
			System.copyIfNewer(ndllPath, ndllDestPath);
			if(System.hostPlatform != HostPlatform.WINDOWS)
				System.runCommand("", "chmod", ["755", binPath]);
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
			project.templatePaths = [ Path.combine (libraryFolder, "templates") ].concat (project.templatePaths);

			var builder = new CppiaPlatform(command, project, project.targetFlags);
			builder.execute(additionalArgs);
		}
	}

	//modified from NME CommandLineTools
	static public function export(info:String, filter:String)
	{
		try
		{
			var match = filter!="" && filter!=null ?  new EReg(filter,"") : null;

			var content = File.getContent(info);
			var result = new Array<String>();
			var allMatched = true;
			for(line in content.split("\n"))
			{
				if (match!=null && match.match(line))
					result.push(line);
				else
					allMatched = false;
			}
			if (match!=null && !allMatched)
			{
				File.saveBytes(info, haxe.io.Bytes.ofString(result.join("\n")));
			}
		}
		catch(e:Dynamic)
		{
			trace('Error cleaning export file $info $e');
		}
	}
}
