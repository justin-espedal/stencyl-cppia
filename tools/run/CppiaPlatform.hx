package;

import haxe.Template;
import hxp.*;
import lime.tools.*;
import lime.project.*;
import sys.io.File;
import sys.FileSystem;

class CppiaPlatform extends PlatformTarget {
	
	
	private var applicationDirectory:String;
	private var executablePath:String;
	private var targetType:String = "stencyl-cppia";
	
	public static var hostExecutablePath = "";
	public static var projectPath = "";
	
	public function new (command:String, _project:HXProject, targetFlags:Map <String, String> ) {
		
		super (command, _project, targetFlags);
		
		targetDirectory = Path.combine (project.app.path, project.config.getString ("stencyl-cppia.output-directory", "stencyl-cppia"));
		applicationDirectory = targetDirectory;
		executablePath = applicationDirectory + "/" + project.app.file + ".cppia";
	}
	
	
	public override function build ():Void {
		
		var type = "release";
		
		if (project.debug) {
			
			type = "debug";
			
		}
		
		var hxml = targetDirectory + "/haxe/" + type + ".hxml";
		
		System.mkdir (targetDirectory);
		
		for (dependency in project.dependencies) {
			
			if (StringTools.endsWith (dependency.path, ".dll")) {
				
				var fileName = Path.withoutDirectory (dependency.path);
				System.copyIfNewer (dependency.path, applicationDirectory + "/" + fileName);
				
			}
			
		}
		
		var platform = System.hostPlatform;
		var is64 = System.hostArchitecture == HostArchitecture.X64;
		
		if(platform == HostPlatform.WINDOWS)
			is64 = false;
		
		var platformID = platform + (is64  ? "64" : "");
		platformID = platformID.substr(0, 1).toUpperCase() + platformID.substr(1);
		
		var libExtension = switch(platform) {
			case WINDOWS:
				".dll";
			case MAC:
				".dylib";
			case LINUX:
				".dso";
			case _:
				"";
		}
		
		for (ndll in project.ndlls)
		{
			ProjectHelper.copyLibrary (project, ndll, platformID, "", (ndll.haxelib != null && (ndll.haxelib.name == "hxcpp" || ndll.haxelib.name == "hxlibc")) ? libExtension : ".ndll", applicationDirectory, project.debug);
		}
		
		var icons = project.icons;
		
		if (icons.length == 0) {
			
			icons = [ new Icon (System.findTemplate (project.templatePaths, "default/icon.svg")) ];
			
		}
		
		//IconHelper.createIcon (project.icons, 32, 32, Path.combine (applicationDirectory, "icon.png"));
		
		var haxeArgs = [ hxml ];
		var flags = [];
		
		if (!project.environment.exists ("SHOW_CONSOLE")) {
			
			haxeArgs.push ("-D");
			haxeArgs.push ("no_console");
			flags.push ("-Dno_console");
			
		}
		
		System.runCommand("", "haxe", haxeArgs);
	}
	
	
	public override function clean ():Void {
		
		if (FileSystem.exists (targetDirectory)) {
			
			System.removeDirectory (targetDirectory);
			
		}
		
	}
	
	
	public override function deploy ():Void {

	}
	
	
	public override function display ():Void {
		
		var type = "release";
		
		if (project.debug) {
			
			type = "debug";
			
		}
		
		var hxml = System.findTemplate (project.templatePaths, targetType + "/hxml/" + type + ".hxml");
		var template = new Template (File.getContent (hxml));
		Sys.println (template.execute (generateContext ()));
		
	}
	
	
	private function generateContext ():Dynamic {
		
		var context = project.templateContext;
		
		context.CPP_DIR = targetDirectory + "/" + project.app.file + ".cppia";
		context.BUILD_DIR = targetDirectory;

		var prefix = null;

		context.HAXE_FLAGS =
			context.HAXE_FLAGS + "\n" +
			[
				for(arg in additionalArguments)
					if(arg == "-D") arg + " "
					else            arg + "\n"
			].join("");

		return context;
		
	}
	
	
	public override function rebuild ():Void {
		
	}
	
	
	public override function run ():Void {
		
		var scriptFolder = Path.combine(projectPath, targetDirectory);
		var fullScriptPath = Path.combine(projectPath, executablePath);

		System.runCommand(scriptFolder, hostExecutablePath, [fullScriptPath]);
		
	}
	
	
	public override function update ():Void {
		
		AssetHelper.processLibraries (project, targetDirectory);
		
		if (project.targetFlags.exists ("xml")) {
			
			project.haxeflags.push ("-xml " + targetDirectory + "/types.xml");
			
		}
		
		for (asset in project.assets) {

			if (asset.embed && asset.sourcePath == "") {

				var path = Path.combine (targetDirectory + "/obj/tmp", asset.targetPath);
				System.mkdir (Path.directory (path));
				AssetHelper.copyAsset (asset, path);
				asset.sourcePath = path;

			}

		}
		
		var context = generateContext ();
		context.OUTPUT_DIR = targetDirectory;

		System.mkdir (targetDirectory);
		System.mkdir (targetDirectory + "/haxe");
		
		//SWFHelper.generateSWFClasses (project, targetDirectory + "/haxe");
		
		ProjectHelper.recursiveSmartCopyTemplate (project, "haxe", targetDirectory + "/haxe", context);
		ProjectHelper.recursiveSmartCopyTemplate (project, targetType + "/hxml", targetDirectory + "/haxe", context);
		
		for (asset in project.assets) {
			
			if (asset.embed != true) {
				
				var path = Path.combine (applicationDirectory, asset.targetPath);
				
				if (asset.type != AssetType.TEMPLATE) {
					
					System.mkdir (Path.directory (path));
					AssetHelper.copyAssetIfNewer (asset, path);
					
				} else {
					
					System.mkdir (Path.directory (path));
					AssetHelper.copyAsset (asset, path, context);
					
				}
				
			}
			
		}
		
		AssetHelper.createManifest (project, Path.combine (applicationDirectory, "manifest"));
		
	}
	
	
	@ignore public override function install ():Void {}
	@ignore public override function trace ():Void {}
	@ignore public override function uninstall ():Void {}
	
	
}