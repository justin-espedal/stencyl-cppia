import sys.*;
import sys.io.*;

using Lambda;
using StringTools;

class ListClassesMain
{
	public static function main()
	{
		var stencylSource = "../../../../stencyl/1,00";
		var allFiles = [];
		
		addHaxeFiles(stencylSource, allFiles, []);
		
		//or put this in an "include" macro in host hxml
		allFiles.push("scripts.MyAssets");
		allFiles.push("scripts.MyScripts");
		
		var imports = allFiles
					.filter(function(name) return name != "com.stencyl.utils.cpmstar.AdLoader")
					.map(function(name) return 'import $name;' );
		
		var output = imports.join("\n");
		
		output +=
			"\n\n" +
			"class AllStencyl\n" +
			"{\n" +
			"}\n";
		
		File.saveContent("../../engine/src/AllStencyl.hx", output);
	}
	
	public static function addHaxeFiles(path, list, parts:Array<String>)
	{
		for(filename in FileSystem.readDirectory(path))
		{
			if(filename.endsWith(".hx"))
			{
				list.push(parts.concat([filename.split(".")[0]]).join("."));
			}
			else if(FileSystem.isDirectory(path + "/" + filename))
			{
				addHaxeFiles(path + "/" + filename, list, parts.concat([filename]));
			}
		}
	}
}

