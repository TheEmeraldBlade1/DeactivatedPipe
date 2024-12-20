package;

#if sys
import sys.FileSystem;
#end

import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Paths
{

    static final audioExtension:String = "ogg";

    inline static public function file(key:String, location:String, extension:String):String{
        if(location.endsWith("/")){ location = location.substring(0, location.length-1); } //Prevent people from accidentally using 2 slashes.
        var data:String = 'assets/$location/$key.$extension';
        return data;

    }

    inline static public function image(key:String, forceLoadFromDisk:Bool = false):Dynamic{

        var data:String = file(key, "images", "png");

        if(ImageCache.exists(data) && !forceLoadFromDisk){
            //trace(key + " is in the cache");
            return ImageCache.get(data);
        }
        else{
            //trace(key + " loading from file");
            return data;
        }
            
    }

    static public function module(key:String, ?location:String = "scripts", ?extension:String = "hxs")
    {
        return file(key, location, extension);
    }

    static public function luaScriptMods(key:String = "")
    {
        return "LuaScripts/" + key;
    }

    inline static public function xml(key:String, ?location:String = "images"){
        return file(key, location, "xml");
    }

    inline static public function text(key:String, ?location:String = "data"){
        return file(key, location, "txt");
    }

    inline static public function json(key:String, ?location:String = "data/songs"){
        return file(key, location, "json");
    }

    inline static public function sound(key:String){
        return file(key, "sounds", audioExtension);
    }

    inline static public function music(key:String){
        return file(key, "music", audioExtension);
    }

    inline static public function voices(key:String, type:String = ""){
        if(type.length > 0){ type = "-" + type; }
        return 'assets/songs/$key/Voices$type.$audioExtension';
    }

    inline static public function inst(key:String){
        return 'assets/songs/$key/Inst.$audioExtension';
    }

    inline static public function getSparrowAtlas(key:String){
        return FlxAtlasFrames.fromSparrow(image(key), xml(key));
    }

    inline static public function getPackerAtlas(key:String){
        return FlxAtlasFrames.fromSpriteSheetPacker(image(key), text(key, "images"));
    }

    inline static public function getTextureAtlas(key:String){
        return 'assets/images/$key';
    }

    inline static public function video(key:String){
        return file(key, "videos", "mp4");
    }
    
    inline static public function font(key:String, ?extension:String = "ttf"){
        return file(key, "fonts", extension);
    }

    inline static public function shader(key:String, ?extension:String = "frag"){
        return file(key, "data/shaders", extension);
    }

}