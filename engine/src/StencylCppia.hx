package;

import AllStencyl;
import DefaultAssetLibrary;

import hxcpp.StaticSqlite;
import hxcpp.StaticMysql;
import hxcpp.StaticRegexp;
import hxcpp.StaticStd;
import hxcpp.StaticZlib;

@:build(cpp.cppia.HostClasses.include())
class StencylCppia
{
	public static var gamePath:String;

	public static function run(source:String)
	{
		untyped __global__.__scriptable_load_cppia(source);
	}

	public static function main()
	{
		var args = Sys.args();
		var script = args[0];
		
		var delimiter = Std.int(Math.max(script.lastIndexOf("/"), script.lastIndexOf("\\")));
		gamePath = script.substring(0, delimiter);

		#if (!scriptable && !doc_gen)
			#error "Please define scriptable to use cppia"
		#end
		if (script==null)
		{
			Sys.println("Usage : Cppia scriptname");
		}
		else
		{
			var source = sys.io.File.getContent(script);
			run(source);
		}
	}
}