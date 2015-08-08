package;

import haxe.Unserializer;
import sys.*;
import sys.io.*;

import lime.tools.helpers.*;
import lime.project.*;
//import lime.utils.Log;

using Lambda;
using StringTools;

class RunMain
{
	public static function main()
	{
		var arguments = Sys.args();
		var libraryFolder = PathHelper.getHaxelib (new Haxelib ("stencyl-cppia"));
		libraryFolder = libraryFolder.substring(0, libraryFolder.length - 1);
		var command = arguments[0];
		
		//All generated binaries go into Stencyl Workspace

		var workspace =
			if(arguments.indexOf("-stencyl-workspace") != -1)
				arguments[arguments.indexOf("-stencyl-workspace") + 1].urlDecode()
			else
				null;

		if(workspace == null)
		{
			/*if(arguments.has("-dev"))
			{
				workspace = Sys.getCwd();
				trace("Passed -dev, so using cwd as workspace.");
			}
			else*/
			{
				trace("Must pass -stencyl-workspace path/to/stencylworks to run stencyl-cppia");
				return;
			}
		}

		trace('workspace: $workspace');

		//Platform info

		var platform = PlatformHelper.hostPlatform;
		var is64 = PlatformHelper.hostArchitecture == Architecture.X64;
		
		if(platform == Platform.WINDOWS)
			is64 = false;
		
		var platformID = platform + (is64  ? "64" : "");
		var architectureString = (is64 ? "64" : "32");
		var platformType = switch(platform) {
			case WINDOWS | MAC | LINUX:
				"desktop";
			case ANDROID | IOS:
				"mobile";
			case _:
				"";
		}

		//Binary locations

		var cppiaFolder = PathHelper.combine(workspace, "cppia");
		FileSystem.createDirectory(cppiaFolder);

		var binFolder = '$cppiaFolder/bin/$platformID';
		FileSystem.createDirectory(binFolder);

		var binSuffix = (platform == Platform.WINDOWS ? ".exe" : "");
		var hasBin = FileSystem.exists('$binFolder/StencylCppia$binSuffix'); 

		CppiaPlatform.hostExecutablePath = '$binFolder/StencylCppia$binSuffix';

		//Setup

		if(!hasBin || command == "setup")
		{
			var devSetup = arguments.has("-dev");

			if(devSetup)
			{
				var stencylClassList = ListClasses.list("stencyl", "AllStencyl", ["scripts.MyAssets", "scripts.MyScripts"], ListClasses.exclude);
				File.saveContent('$libraryFolder/engine/src/AllStencyl.hx', stencylClassList);
			}

			var tempFolder = '$cppiaFolder/temp/$platformID';
			FileSystem.createDirectory(tempFolder);

			var haxeArgs =
			[
				'compile-common.hxml',

				'-D', 'HXCPP_M$architectureString',
				'-D', '$platform',
				'-D', '$platformType',

				'-cpp', '$tempFolder'
			];

			var exportFolder = "";

			if(devSetup)
			{
				exportFolder = '$libraryFolder/export';
				FileSystem.createDirectory(exportFolder);
				
				haxeArgs.push('-D');
				haxeArgs.push('dll_export=$exportFolder/export_classes.info');
				haxeArgs.push('-D');
				haxeArgs.push('no-compilation');
			}

			try { Sys.setCwd ('$libraryFolder/engine/hxml'); } catch (e:Dynamic) {}
			ProcessHelper.runCommand ("", "haxe", haxeArgs);

			if(devSetup)
			{
				var srcFolder = '$libraryFolder/engine/src';
				//export('$exportFolder/export_classes.info', "^(class|enum|interface)", '$exportFolder');
				FileSystem.createDirectory('$exportFolder/scripts');
				FileHelper.copyIfNewer('$srcFolder/DefaultAssetLibrary.hx', '$exportFolder/DefaultAssetLibrary.hx');
				FileHelper.copyIfNewer('$srcFolder/scripts/MyAssets.hx', '$exportFolder/scripts/MyAssets.hx');
				FileHelper.copyIfNewer('$srcFolder/scripts/MyScripts.hx', '$exportFolder/scripts/MyScripts.hx');
			}
			else
			{
				FileHelper.copyIfNewer('$tempFolder/StencylCppia$binSuffix', '$binFolder/StencylCppia$binSuffix');
			}
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
			project.templatePaths = [ PathHelper.combine (libraryFolder, "templates") ].concat (project.templatePaths);
			
			var builder = new CppiaPlatform(command, project, project.targetFlags);
			builder.execute(additionalArgs);
		}

		//else
		//{
		//	trace('$command is not a valid command');
		//}
	}

	//taken from NME CommandLineTools
	static public function export(info:String, filter:String, sourceDir:String)
	{
		try
		{
			var match = filter!="" && filter!=null ?  new EReg(filter,"") : null;
			var fileMatch = sourceDir!="" && sourceDir!=null ? ~/^file (\S*) ([^\r]*)/ : null;

			var content = File.getContent(info);
			var result = new Array<String>();
			var allMatched = true;
			var sourceCount = 0;
			var haxeStdPath = Sys.getEnv("HAXE_STD_PATH");
			var stdFile = "file " + haxeStdPath;
			for(line in content.split("\n"))
			{
				if (match!=null && match.match(line))
					result.push(line);
				else
					allMatched = false;

				if (fileMatch!=null && !line.startsWith(stdFile) && fileMatch.match(line))
				{
					var dest = fileMatch.matched(1);
					if (PathHelper.isAbsolute(dest))
					{
						//Log.verbose("Unusual absolute path destination " + dest);
					}
					else
					{
						var source = unquote(fileMatch.matched(2));
						FileHelper.copyIfNewer(source, sourceDir + "/" + dest);
						sourceCount++;
					}
				}
			}
			if (match!=null && !allMatched)
			{
				File.saveBytes(info, haxe.io.Bytes.ofString(result.join("\n")));
				//Log.verbose("Cleaned export file " + info);
			}

			if (sourceCount>0)
			{
				//Log.verbose('Exported $sourceCount files to $sourceDir');
			}
		}
		catch(e:Dynamic)
		{
			//Log.error('Error cleaning export file $info $e');
		}
	}

	public static function unquote(x:String) : String
	{
		var result:String = "";
		while(true)
		{
			var slash = x.indexOf("\\");
			if (slash<0)
				return result + x;
			result += x.substr(0,slash);
			var next = x.substr(slash+1,1);
			if (next=="n")
				result += "\n";
			else if (next=="s")
				result += " ";
			else
				result += next;
			x = x.substr(slash+2);
		}
		return null;
	}
}