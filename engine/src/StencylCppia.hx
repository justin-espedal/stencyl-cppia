import AllStencyl;
import DefaultAssetLibrary;

#if cpp
import hxcpp.StaticSqlite;
import hxcpp.StaticMysql;
import hxcpp.StaticRegexp;
import hxcpp.StaticStd;
import hxcpp.StaticZlib;
#end

@:build(cpp.cppia.HostClasses.include())
class StencylCppia
{
	public static function run(source:String)
	{
		untyped __global__.__scriptable_load_cppia(source);
	}

	public static function main()
	{
		var script = Sys.args()[0];
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