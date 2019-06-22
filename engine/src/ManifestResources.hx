package;

import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets;

import sys.FileSystem;

@:access(lime.utils.Assets)
@:keep @:dox(hide) class ManifestResources {
	
	public static var preloadLibraries:Array<AssetLibrary>;
	public static var preloadLibraryNames:Array<String>;
	
	public static function init (config:Dynamic):Void {
		
		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();
		
		var rootPath = StencylCppia.gamePath + "/";
		Assets.defaultRootPath = "";
		
		var data, manifest, library;
		
		Assets.libraryPaths["default"] = rootPath + "manifest/default.json";
		
		library = Assets.getLibrary ("default");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("default");
	}
}