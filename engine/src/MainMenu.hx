package;

import hxp.*;
import lime.tools.*;

import openfl.Lib;
import openfl.display.*;
import openfl.events.*;
import openfl.geom.*;
import openfl.text.*;
import openfl.utils.*;

import sys.*;
import sys.io.*;

@:access(lime.app.Application)
@:access(lime.Assets)
@:access(openfl.display.Stage)

class MainMenu extends Sprite
{
  public static var GAMES_GENERATED:String;

  public static inline var WIDTH = 640;
  public static inline var HEIGHT = 480;

  public static function main () {
    
    var config = {
      
      build: "1",
      company: "Stencyl",
      file: "MainMenu",
      fps: 65,
      name: "StencylCppia",
      orientation: "landscape",
      packageName: "com.stencyl.cppiahost",
      version: "1.1",
      windows: [
        
        {
          antialiasing: 0,
          background: 0,
          borderless: false,
          depthBuffer: false,
          display: 0,
          fullscreen: false,
          hardware: true,
          height: HEIGHT,
          parameters: {},
          resizable: false,
          stencilBuffer: true,
          title: "StencylCppia",
          vsync: true,
          width: WIDTH,
          x: null,
          y: null
        },
      ]
      
    };
  
    var app = new openfl.display.Application ();
    
    app.meta["build"] = "1";
    app.meta["company"] = "Stencyl";
    app.meta["file"] = "MainMenu";
    app.meta["name"] = "StencylCppia";
    app.meta["packageName"] = "com.stencyl.cppiahost";
    
    var attributes:lime.ui.WindowAttributes = {
      
      allowHighDPI: false,
      alwaysOnTop: false,
      borderless: false,
      element: null,
      frameRate: 65,
      fullscreen: false,
      height: HEIGHT,
      hidden: false,
      maximized: false,
      minimized: false,
      parameters: {},
      resizable: false,
      title: "StencylCppia",
      width: WIDTH,
      x: null,
      y: null,
      
    };
    
    attributes.context = {
      
      antialiasing: 0,
      background: 0,
      colorDepth: 32,
      depth: true,
      hardware: true,
      stencil: true,
      type: null,
      vsync: true
      
    };
    
    if (app.window == null) {
      
      if (config != null) {
        
        for (field in Reflect.fields (config)) {
          
          if (Reflect.hasField (attributes, field)) {
            
            Reflect.setField (attributes, field, Reflect.field (config, field));
            
          } else if (Reflect.hasField (attributes.context, field)) {
            
            Reflect.setField (attributes.context, field, Reflect.field (config, field));
            
          }
          
        }
        
      }
      
    }
    
    app.createWindow (attributes);
    
    var mainMenu = new MainMenu();
    
    var preloader = new openfl.display.Preloader (null);
    preloader.onComplete.add (function() {
      app.window.stage.addChild(mainMenu);
      mainMenu.init();
    });
    
    app.preloader.onProgress.add (function (loaded, total) {
      @:privateAccess preloader.update (loaded, total);
    });
    app.preloader.onComplete.add (function () {
      @:privateAccess preloader.start ();
    });
    
    var result = app.exec ();
    Sys.exit (result);
  }

  private var menu:Menu;

  private function init():Void
	{
		var platform = Path.standardize(Sys.getCwd(), false);

    var parts = platform.split("/");
    parts = parts.slice(0, parts.length - 3);

    var stencylworks = parts.join("/");
    GAMES_GENERATED = '$stencylworks/games-generated';

    var cppiaGames = [];

    for(game in FileSystem.readDirectory(GAMES_GENERATED))
    {
      if(FileSystem.exists('$GAMES_GENERATED/$game/Export/cppia/$game.cppia'))
        cppiaGames.push(game);
    }

    menu = new Menu();
    addChild(menu);
    menu.graphics.beginFill(0xFFFFFF);
    menu.graphics.drawRect(0, 0, WIDTH - Menu.PADDING * 2, HEIGHT - Menu.PADDING * 2);
    menu.graphics.endFill();
    menu.x = Menu.PADDING;
    menu.y = Menu.PADDING;

    for(cppiaGame in cppiaGames)
    {
      menu.addMenuItem(new MenuItem(cppiaGame));
    }
	}
}

class Menu extends Sprite
{
  public static inline var WIDTH = 620;
  public static inline var HEIGHT = 460;
  public static inline var PADDING = 10;
  public static inline var COLUMNS = 2;

  public var items:Array<MenuItem> = [];

  public function new()
  {
    super();
  }

  public function addMenuItem(item:MenuItem)
  {
    var index = items.length;

    items.push(item);
    addChild(item);

    var row = Std.int(index / COLUMNS);
    var col = Std.int(index % COLUMNS);

    item.x = PADDING + col * (MenuItem.WIDTH + PADDING);
    item.y = PADDING + row * (MenuItem.HEIGHT + PADDING);
  }
}

class MenuItem extends Sprite
{
  public static inline var WIDTH = (Menu.WIDTH - (Menu.COLUMNS + 1) * 10) / Menu.COLUMNS;
  public static inline var HEIGHT = 50;

  public static var menuItemFormat = {
    var format:TextFormat = new TextFormat();
    format.size = 20;
    //format.align = TextFormatAlign.CENTER;
    format;
  }

  public static var sizes = [16, 24, 32, 48, 72, 76, 96, 120, 128, 152, 256, 512, 1024];

  public static var iconSize = {
    var useSize = 16;

    for(curSize in sizes)
      if(curSize <= HEIGHT)
        useSize = curSize;
    useSize;
  }

  public var game:String;

  public function new(game:String)
  {
    super();

    this.game = game;

    color(0x888888);

    var icon = getIcon(game);
    addChild(icon);
    var iconPad = (HEIGHT - iconSize) / 2;
    icon.x = iconPad;
    icon.y = iconPad;

    var text:TextField = new TextField();
    text.defaultTextFormat = menuItemFormat;
    text.text = game;
    text.selectable = false;
    addChild(text);
    text.x = iconPad * 2 + icon.width + 5;
    text.y = 10;
    text.width = width - 10 - text.x;
    text.height = height - 20;

    addEventListener(MouseEvent.CLICK, onClick);
    addEventListener(MouseEvent.ROLL_OVER, onRollOver);
    addEventListener(MouseEvent.ROLL_OUT, onRollOut);
  }

  public static function getIcon(game:String):Bitmap
  {
    var path = '${MainMenu.GAMES_GENERATED}/$game/Icon-$iconSize.png';
    if(!FileSystem.exists(path))
    {
      trace('Couldn\'t load icon from path: $path');
      return new Bitmap(new BitmapData(iconSize, iconSize, false, 0xFFFFFF));
    }

    var bytes = File.getBytes(path);
    var bitmapData = BitmapData.fromBytes(bytes);

    return new Bitmap(bitmapData);
  }

  private function onClick(event:MouseEvent)
  {
    var path = Path.standardize(Sys.programPath(), false).split("/");
    var folder = path.slice(0, path.length - 1).join("/");
    System.runCommand(folder, path.pop(), ['${MainMenu.GAMES_GENERATED}/$game/Export/cppia/$game.cppia']);
  }

  private function onRollOver(event:MouseEvent)
  {
    color(0x8888DD);
  }

  private function onRollOut(event:MouseEvent)
  {
    color(0x888888);
  }

  private function color(c:Int)
  {
    graphics.clear();
    graphics.lineStyle(2, 0xAAAAAA);
    graphics.beginFill(c);
    graphics.drawRect(0, 0, WIDTH, HEIGHT);
    graphics.endFill();
  }
}
