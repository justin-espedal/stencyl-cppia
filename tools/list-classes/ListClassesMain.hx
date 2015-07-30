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
					.filter(function(name) return !exclude.exists(name))
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
	
	public static var exclude = {
		var a = 
		[
			"com.stencyl.utils.FastIntHash", //compile error
			"com.stencyl.utils.HashMap", //blank file
			"com.stencyl.utils.Kongregate",
			"com.stencyl.utils.cpmstar.AdLoader",
			"com.stencyl.utils.mochi.MochiAd",
			"com.stencyl.utils.mochi.MochiCoins",
			"com.stencyl.utils.mochi.MochiDigits",
			"com.stencyl.utils.mochi.MochiEventDispatcher",
			"com.stencyl.utils.mochi.MochiEvents",
			"com.stencyl.utils.mochi.MochiInventory",
			"com.stencyl.utils.mochi.MochiScores",
			"com.stencyl.utils.mochi.MochiServices",
			"com.stencyl.utils.mochi.MochiSocial",
			"com.stencyl.utils.mochi.MochiUserData",
			"com.stencyl.utils.newgrounds.API",
			"com.stencyl.utils.newgrounds.APICommand",
			"com.stencyl.utils.newgrounds.APIConnection",
			"com.stencyl.utils.newgrounds.APIEvent",
			"com.stencyl.utils.newgrounds.APIEventDispatcher",
			"com.stencyl.utils.newgrounds.assets.DefaultMedalIcon",
			"com.stencyl.utils.newgrounds.assets.DefaultSaveIcon",
			"com.stencyl.utils.newgrounds.BitmapLoader",
			"com.stencyl.utils.newgrounds.Bridge",
			"com.stencyl.utils.newgrounds.components.APIConnector",
			"com.stencyl.utils.newgrounds.components.FlashAd",
			"com.stencyl.utils.newgrounds.components.FlashAdBase",
			"com.stencyl.utils.newgrounds.components.MedalPopup",
			"com.stencyl.utils.newgrounds.components.Preloader",
			"com.stencyl.utils.newgrounds.components.SaveBrowser",
			"com.stencyl.utils.newgrounds.components.ScoreBrowser",
			"com.stencyl.utils.newgrounds.components.VoteBar",
			"com.stencyl.utils.newgrounds.crypto.MD5",
			"com.stencyl.utils.newgrounds.crypto.RC4",
			"com.stencyl.utils.newgrounds.encoders.BaseN",
			"com.stencyl.utils.newgrounds.encoders.json.JSON",
			"com.stencyl.utils.newgrounds.encoders.PNGEncoder",
			"com.stencyl.utils.newgrounds.Logger",
			"com.stencyl.utils.newgrounds.Medal",
			"com.stencyl.utils.newgrounds.SaveFile",
			"com.stencyl.utils.newgrounds.SaveGroup",
			"com.stencyl.utils.newgrounds.SaveKey",
			"com.stencyl.utils.newgrounds.SaveQuery",
			"com.stencyl.utils.newgrounds.SaveRating",
			"com.stencyl.utils.newgrounds.Score",
			"com.stencyl.utils.newgrounds.ScoreBoard",
			"com.stencyl.utils.newgrounds.shims.APIShim",
			"com.stencyl.utils.SizedIntHash" //blank file
		];

		var m = new Map<String,Int>();
		a.iter(function(e) m.set(e, 1));
		m;
	}
}

