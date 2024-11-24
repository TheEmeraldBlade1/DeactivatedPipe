//To run it, create a folder and put this file inside. cd to that folder and run "haxe -main Converter --interp" (tested on MacOS only! may not work on Windows).
package;

import sys.FileSystem;
import haxe.Json;
import sys.io.File;

using StringTools;

class Converter
{
	static final FPS_PLUS_API = "1.0.0";
	static final EXPORT_DIR = "export";

	static final imageRedirect:Map<String, String> = [
		"icons" => "ui/healthIcons"
	];

	static var psychModPath:String = "";
	static var fpsModPath:String = "";

	//Trace Color
	public static final RED="\033[0;31m";
	public static final WHITE="\033[0m";
	public static final GREEN="\033[0;32m";

	public static function main():Void
	{
		//Create export folder if it doesn't exists
		if (!FileSystem.exists(FileSystem.absolutePath(EXPORT_DIR)))
			FileSystem.createDirectory(EXPORT_DIR);
		//Set mod paths
		psychModPath = "";
		trace("Enter Psych Mod Folder Path! (where pack.json is located)");
		psychModPath = Sys.stdin().readLine().trim();

		//Starts Converting
		var metadata:ModMetadata = convertModMeta();
		
		if (FileSystem.exists(FileSystem.absolutePath(EXPORT_DIR+"/"+metadata.title))){
			trace(RED + '[Error] Export Folder Already Exists on (${FileSystem.absolutePath(EXPORT_DIR+"/"+metadata.title)}/)!!');
			return;
		} else {
			FileSystem.createDirectory(EXPORT_DIR+"/"+metadata.title);
			fpsModPath = FileSystem.absolutePath(EXPORT_DIR+"/"+metadata.title);
		}

		File.saveContent(fpsModPath + "/meta.json", Json.stringify(convertModMeta(), "\t"));
		if (FileSystem.exists(FileSystem.absolutePath(psychModPath + "/pack.png")))
			File.copy(psychModPath + "/pack.png", fpsModPath + "/icon.png");

		copyImages();

		convertSongs();
		convertWeeks();

		convertCharacters();

		convertStages();
		//convertScripts();

		trace(GREEN + 'Successfully Converted ${metadata.title}!');
	}

	static function convertModMeta():ModMetadata
	{
		final psychPack:Dynamic = Json.parse(File.getContent(psychModPath + "/pack.json"));

		if (!FileSystem.exists(psychModPath)){
			trace(RED + '[Error] No Mod pack.json Exist on ($psychModPath/pack.json)!!');
			return null;
		}

		var pack:ModMetadata = {
			title: psychPack.name,
			description: psychPack.description,
			homepage: "https://github.com/ShadowMario/FNF-PsychEngine",
			contributors: [],
			api_version: FPS_PLUS_API,
			mod_version: "1.0.0" //I think this should be "Psych Engine v???"" like shit
		};

		//Converts Credit data if exists
		if (FileSystem.exists(psychModPath + "/data/credits.txt")){
			final creditData:Array<String> = File.getContent(psychModPath + "/data/credits.txt").split('\n');
			for(credit in creditData)
			{
				var arr:Array<String> = credit.split("::");
				if(arr.length >= 2){
					pack.contributors.push({
						name: arr[0],
						role: arr[2],
						url: arr[3]
					});
				}
			}
		}

		return pack;
	}

	static function convertSongs():Void{
		//Copy Song Files
		FileSystem.createDirectory(fpsModPath + "/songs");

		for (dir in FileSystem.readDirectory(psychModPath + "/songs/")){
			if (FileSystem.isDirectory(psychModPath + "/songs/" + dir)){
				FileSystem.createDirectory(fpsModPath + "/songs/" + dir);
				for (file in FileSystem.readDirectory(psychModPath + "/songs/" + dir +"/")){
					File.copy(psychModPath + "/songs/" + dir + "/" + file, fpsModPath + "/songs/" + dir + "/" + file);
				}
			}
		}
		
		//Copy Chart Files
		FileSystem.createDirectory(fpsModPath + "/data/songs");
		for (dir in FileSystem.readDirectory(psychModPath + "/data/")){
			if (FileSystem.isDirectory(psychModPath + "/data/" + dir)){
				FileSystem.createDirectory(fpsModPath + "/data/songs/" + dir);
				for (file in FileSystem.readDirectory(psychModPath + "/data/" + dir +"/")){
					if (!file.endsWith(".json"))
						continue;

					final renamedFile = file.replace(" ", "-").toLowerCase();
					File.copy(psychModPath + "/data/" + dir + "/" + file, fpsModPath + "/data/songs/" + dir + "/" + renamedFile);
				}

				final metadata:ModSongMetadata = {
					name: dir,
					artist: "Unknown",
					album: "vol1",
					difficulties: [0, 4, 8],
					//maybe recreate psych behaviour idk???
					dadBeats: [0, 2],
					bfBeats: [0, 2]
				}
				File.saveContent(fpsModPath + "/data/songs/" + dir + "/meta.json", Json.stringify(metadata, "\t"));
			}
		}
	}

	static function convertWeeks():Void{
		FileSystem.createDirectory(fpsModPath + "/append/data/freeplay");
		FileSystem.createDirectory(fpsModPath + "/data/weeks");

		for (file in FileSystem.readDirectory(psychModPath + "/weeks/")){
			if (!file.endsWith(".json"))
				continue;

			var psychWeek = Json.parse(File.getContent(psychModPath + "/weeks/" + file));
			var songList:Array<Dynamic> = psychWeek.songs;

			var week:ModWeek = {
				name: psychWeek.storyName,
				songs: [],
				characters: ["dad", "bf", "gf"]
				//characters: psychWeek.weekCharacters
			}
			for (song in songList){
				week.songs.push(song[0]);
			}
			if (!psychWeek.hideStoryMode)
				File.saveContent(fpsModPath + "/data/weeks/" + file, Json.stringify(week, "\t"));

			//Add to Freeplay if it don't have to hide
			if (!psychWeek.hideFreeplay){
				var str:String = "category | ALL";
				
				for (song in songList)
					str += '\nsong | ${song[0]} | none | [ALL]';
				File.saveContent(fpsModPath + "/append/data/freeplay/songList-bf.txt", str);
			}
		}
	}

	//Copy all of images my head are melted
	static function copyImages():Void{
		FileSystem.createDirectory(fpsModPath + "/images");

		for (dir in FileSystem.readDirectory(psychModPath + "/images/")){
			if (FileSystem.isDirectory(psychModPath + "/images/" + dir)){
				//set redirect directory
				var realDir = dir;
				if (imageRedirect.exists(dir))
					realDir = imageRedirect[dir];
				FileSystem.createDirectory(fpsModPath + "/images/" + realDir);

				for (file in FileSystem.readDirectory(psychModPath + "/images/" + dir +"/")){
					File.copy(psychModPath + "/images/" + dir + "/" + file, fpsModPath + "/images/" + realDir + "/" + file);
				}
			}
		}
	}

	static function convertCharacters():Void{
		FileSystem.createDirectory(fpsModPath + "/data/characters");

		for (character in FileSystem.readDirectory(psychModPath + "/characters/")){
			if (!character.endsWith(".json"))
				continue;

			final psychChar:Dynamic = Json.parse(File.getContent(psychModPath + "/characters/" + character));

			//uh i think this is awesome
			var charScript = 'class ${character.split(".json")[0]} extends CharacterInfoBase{\n	public function new(){\n		super();';
			
			//"Convert" Anims
			var animList:Array<Dynamic> = psychChar.animations;
			for (anim in animList){
				if (anim.indices != [])
					charScript += '\n		addByPrefix("${anim.anim}", offset(${anim.offsets[0]}, ${anim.offsets[1]}), "${anim.name}", ${anim.fps}, loop(${anim.loop}));';
				else 
					charScript += '\n		addByIndices("${anim.anim}", offset(${anim.offsets[0]}, ${anim.offsets[1]}), "${anim.name}", ${anim.indices.toString()}, "", ${anim.fps}, loop(${anim.loop}));';
			}

			//Convert metadata
			charScript += '\n\n		info.antialiasing = ${!psychChar.no_antialiasing};';
			charScript += '\n		info.spritePath = "${psychChar.image}";';
			charScript += '\n		addExtraData("reposition", ${psychChar.position.toString()});';
			charScript += '\n		info.iconName = "${psychChar.healthicon}";';
			charScript += '\n		info.facesLeft = ${psychChar.flip_x};';
			charScript += '\n		info.healthColor = ${rgbToHex(psychChar.healthbar_colors[0], psychChar.healthbar_colors[1], psychChar.healthbar_colors[2])};';
			charScript += '\n		info.focusOffset.set(${psychChar.camera_position[0]}, ${psychChar.camera_position[1]});';
			charScript += '\n		addExtraData("scale", ${psychChar.scale});';

			charScript += "\n	}\n}";
			File.saveContent(fpsModPath + "/data/characters/" + character.split(".json")[0] + ".hxc", charScript);
		}
	}

	//Converts Stage verry wip yet!! only supports character positioning
	static function convertStages():Void{
		FileSystem.createDirectory(fpsModPath + "/data/stages");

		for (stage in FileSystem.readDirectory(psychModPath + "/stages/")){
			if (!stage.endsWith(".json"))
				continue;

			final psychStage:Dynamic = Json.parse(File.getContent(psychModPath + "/stages/" + stage));

			var stageScript = 'class ${stage.split(".json")[0]} extends BaseStage{\n	public function new(){\n		super();\n		name = "${stage.split(".json")[0]}";';
			//Json Data
			if(psychStage.defaultZoom != null) stageScript += '\n\n		startingZoom = ${psychStage.defaultZoom};';
			if(psychStage.boyfriend != null) stageScript += '\n		bfStart.set(${psychStage.boyfriend[0]}, ${psychStage.boyfriend[1]});';
			if(psychStage.girlfriend != null) stageScript += '\n		gfStart.set(${psychStage.girlfriend[0]}, ${psychStage.girlfriend[1]});';
			if(psychStage.opponent != null) stageScript += '\n		dadStart.set(${psychStage.opponent[0]}, ${psychStage.opponent[1]});';
			if(psychStage.hide_girlfriend != null) stageScript += '\n		gf.visible = ${psychStage.hide_girlfriend};';

			if(psychStage.camera_boyfriend != null) stageScript += '\n		bfCameraOffset.set(${psychStage.camera_boyfriend[0]}, ${psychStage.camera_boyfriend[1]});';
			if(psychStage.camera_opponent != null) stageScript += '\n		gfCameraOffset.set(${psychStage.camera_opponent[0]}, ${psychStage.camera_opponent[1]});';
			if(psychStage.camera_girlfriend != null) stageScript += '\n		gfCameraOffset.set(${psychStage.camera_girlfriend[0]}, ${psychStage.camera_girlfriend[1]});';

			stageScript += "\n	}\n}";
			File.saveContent(fpsModPath + "/data/stages/" + stage.split(".json")[0] + ".hxc", stageScript);
		}
	}



	//Utilities
	static final hexCodes = "0123456789ABCDEF";
	static function rgbToHex(r:Int, g:Int, b:Int):String
	{
		var hexString = "0xFF";
		//Red
		hexString += hexCodes.charAt(Math.floor(r/16));
		hexString += hexCodes.charAt(r%16);
		//Green
		hexString += hexCodes.charAt(Math.floor(g/16));
		hexString += hexCodes.charAt(g%16);
		//Blue
		hexString += hexCodes.charAt(Math.floor(b/16));
		hexString += hexCodes.charAt(b%16);
		
		return hexString;
	}
}

//Typedefs

typedef ModMetadata = {
	var title:String;
	var description:String;
	var homepage:String;
	var contributors:Array<ModCredit>;
	var api_version:String;
	var mod_version:String;
}

typedef ModCredit = {
	var name:String;
	var role:String;
	var url:String;
}

typedef ModWeek = {
	var name:String;
	var songs:Array<String>;
	var characters:Array<String>;
}

typedef ModSongMetadata = {
	var name:String;
	var artist:String;
	var album:String;
	var difficulties:Array<Int>;
	var dadBeats:Array<Int>;
	var bfBeats:Array<Int>;
}