package cursor;

import flixel.FlxG; // import the cursor class

class Cursor
{
    public function new()
    {
        createDefault();
    }

    public static function createDefault()
    {
        FlxG.mouse.visible = true;
        FlxG.mouse.unload();
        FlxG.log.add("Sexy mouse cursor " + Paths.image("cursor/cursor-default"));
        FlxG.mouse.load(Paths.image("cursor/cursor-default"));
    }

    public static function createPointer()
    {
        FlxG.mouse.visible = true;
        FlxG.mouse.unload();
        FlxG.log.add("Sexy mouse cursor " + Paths.image("cursor/cursor-pointer"));
        FlxG.mouse.load(Paths.image("cursor/cursor-pointer"));
    }

    public static function createCell()
    {
        FlxG.mouse.visible = true;
        FlxG.mouse.unload();
        FlxG.log.add("Sexy mouse cursor " + Paths.image("cursor/cursor-cell"));
        FlxG.mouse.load(Paths.image("cursor/cursor-cell"));
    }

    public static function createGrabbing()
    {
        FlxG.mouse.visible = true;
        FlxG.mouse.unload();
        FlxG.log.add("Sexy mouse cursor " + Paths.image("cursor/cursor-grabbing"));
        FlxG.mouse.load(Paths.image("cursor/cursor-grabbing"));
    }

    public static function unloadCursor()
    {
        FlxG.mouse.visible = false;
        FlxG.mouse.unload();   
    }
}