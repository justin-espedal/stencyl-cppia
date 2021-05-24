package;

import AllStencyl;
import ManifestResources;

import cpp.cppia.Module;

import hxcpp.StaticSqlite;
import hxcpp.StaticMysql;
import hxcpp.StaticRegexp;
import hxcpp.StaticStd;
import hxcpp.StaticZlib;

@:build(cpp.cppia.HostClasses.include())
class StencylCppia
{
	public static var gamePath:String;
	
	public static function run(source:haxe.io.Bytes)
	{
		var module = Module.fromData(source.getData());
		module.boot();
		module.run();
	}
	
	public static function main()
	{
		#if (!scriptable && !doc_gen)
			#error "Please define scriptable to use cppia"
		#end

		var args = Sys.args();

		if(args.length == 0 || args[0] == null)
		{
			trace("Usage : Cppia scriptname");
		}
		else
		{
			runScript(args[0]);
		}
	}

	public static function runScript(script:String)
	{
		var delimiter = Std.int(Math.max(script.lastIndexOf("/"), script.lastIndexOf("\\")));
		gamePath = script.substring(0, delimiter);
		
		var source = sys.io.File.getBytes(script);
		run(source);
	}
}
