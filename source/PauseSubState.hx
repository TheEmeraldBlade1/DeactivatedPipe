package;

import flixel.tweens.FlxEase;
import extensions.flixel.FlxTextExt;
import haxe.Json;
import flixel.text.FlxText;
import flixel.FlxCamera;
import debug.ChartingState;
import flixel.tweens.FlxTween;
import config.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', "Toggle Autoplay", "Options", 'Exit to menu'];
	var curSelected:Int = 0;
	var becomeUseless:Bool = false;

	var pauseMusic:FlxSound;

	var allowControllerPress:Bool = false;

	var camPause:FlxCamera;

	var songName:FlxTextExt;
	var songArtist:FlxTextExt;

	override function create():Void{

		Config.setFramerate(144);

		PlayState.instance.tweenManager.active = false;

		camPause = new FlxCamera();
		camPause.bgColor.alpha = 0;
		FlxG.cameras.add(camPause, false);
		cameras = [camPause];
		
		if (PlayState.storyPlaylist.length > 1 && PlayState.isStoryMode){
			menuItems.insert(2, "Skip Song");
		}
		
		if (!PlayState.isStoryMode){
			menuItems.insert(2, "Chart Editor");
		}

		if (!PlayState.isStoryMode && PlayState.sectionStart){
			menuItems.insert(1, "Restart Section");
		}

		var pauseSongName = "pause/breakfast";

		if(PlayState.instance.metadata != null){
			pauseSongName = PlayState.instance.metadata.pauseMusic;
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music(pauseSongName), true, true);
		
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		pauseMusic.fadeIn(16, 0, 0.7);

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length){
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			songText.itemType = 'Center';
			grpMenuShit.add(songText);
		}

		if(PlayState.instance.metadata != null){
			var distance:Float = 32;

			songName = new FlxTextExt(16, 16, 1280-32, PlayState.instance.metadata.name, 40);
			songName.setFormat(Paths.font("vcr"), 40, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
			songName.borderSize = 3;
			songName.alpha = 0;

			songArtist = new FlxTextExt(16, 32 + 40, 1280-32, PlayState.instance.metadata.artist, 40);
			songArtist.setFormat(Paths.font("vcr"), 40, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
			songArtist.borderSize = 3;
			songArtist.alpha = 0;

			songName.y -= distance;
			songArtist.y -= distance;

			FlxTween.tween(songName, {alpha: 1, y: songName.y + distance}, 0.6, {ease: FlxEase.quartOut});
			FlxTween.tween(songArtist, {alpha: 1, y: songArtist.y + distance}, 0.6, {ease: FlxEase.quartOut, startDelay: 0.25});

			add(songName);
			add(songArtist);
		}

		changeSelection();

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);

		PlayState.instance.stage.pause();
		for(script in PlayState.instance.scripts){ script.pause(); }

		super.create();
	}

	override function update(elapsed:Float){
			
		super.update(elapsed);

		if(!becomeUseless){
			if (Binds.justPressed("menuUp")){
				changeSelection(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);
			}
			if (Binds.justPressed("menuDown")){
				changeSelection(1);
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);
			}
	
			if (Binds.justPressed("menuBack")){
				becomeUseless = true;
				startCountdown();
			}
	
			if (!allowControllerPress ? Binds.justPressedKeyboardOnly("menuAccept") : Binds.justPressed("menuAccept")){
	
				PlayState.instance.tweenManager.active = true;
	
				var daSelected:String = menuItems[curSelected];
	
				switch (daSelected)
				{
					case "Resume":
						becomeUseless = true;
						startCountdown();
						
					case "Restart Song":
						PlayState.instance.tweenManager.clear();
						PlayState.instance.switchState(new PlayState());
						PlayState.sectionStart = false;
						PlayState.replayStartCutscene = false;
						if(PlayState.instance.instSong != null){
							PlayState.overrideInsturmental = PlayState.instance.instSong;
						}
						pauseMusic.fadeOut(0.5, 0);
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);
						becomeUseless = true;
	
					case "Restart Section":
						PlayState.instance.tweenManager.clear();
						PlayState.instance.switchState(new PlayState());
						PlayState.replayStartCutscene = false;
						if(PlayState.instance.instSong != null){
							PlayState.overrideInsturmental = PlayState.instance.instSong;
						}
						pauseMusic.fadeOut(0.5, 0);
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);
						becomeUseless = true;
					
					case "Toggle Autoplay":
						PlayState.autoplay = !PlayState.autoplay;
						PlayState.instance.preventScoreSaving = true;
						PlayState.instance.botplayTxt.visible = !PlayState.instance.botplayTxt.visible;
	
					case "Chart Editor":
						PlayState.instance.tweenManager.clear();
						PlayState.instance.switchState(new ChartingState());
						if(PlayState.instance.instSong != null){
							PlayState.overrideInsturmental = PlayState.instance.instSong;
						}
						pauseMusic.fadeOut(0.5, 0);
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);
						becomeUseless = true;
						
					case "Skip Song":
						PlayState.instance.preventScoreSaving = true;
						PlayState.instance.tweenManager.clear();
						PlayState.instance.endSong();
						pauseMusic.fadeOut(0.5, 0);
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);
						becomeUseless = true;
						
					case "Options":
						PlayState.instance.tweenManager.clear();
						PlayState.instance.switchState(new ConfigMenu());
						ConfigMenu.exitTo = PlayState;
						PlayState.replayStartCutscene = false;
						pauseMusic.fadeOut(0.5, 0);
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);
						becomeUseless = true;
						
					case "Exit to menu":
						PlayState.instance.tweenManager.clear();
						PlayState.sectionStart = false;
						PlayState.instance.returnToMenu();
						pauseMusic.fadeOut(0.5, 0);
						FlxG.sound.play(Paths.sound('cancelMenu'), 0.8);
						becomeUseless = true;
				}
			}
		}

		//This is to work around a flixel issue that makes the controller input state reset on state/sub-state change. idk why it happens
		if(!allowControllerPress && Binds.justReleasedControllerOnly("pause")){
			allowControllerPress = true;
		}
	}

	function unpause(){
		Config.setFramerate(999);
		FlxG.cameras.remove(camPause, true);
		PlayState.instance.stage.unpause();
		for(script in PlayState.instance.scripts){ script.unpause(); }
		close();
	}

	override function destroy(){
		pauseMusic.fadeTween.cancel();
		pauseMusic.destroy();
		if(songName != null){
			FlxTween.cancelTweensOf(songName);
			FlxTween.cancelTweensOf(songArtist);
		}
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members){
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0){
				item.alpha = 1;
			}
		}
	}

	var startTimer:FlxTimer;

	function startCountdown():Void
		{
			if (PlayState.autoplay){
				PlayState.instance.tweenManager.active = true;
				unpause();
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);
			}else{
				var swagCounter:Int = 0;
	
				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
					introAssets.set('default', ['ui/countDown/ready', "ui/countDown/set", "ui/countDown/go"]);
		
					var introAlts:Array<String> = introAssets.get('default');
					var altSuffix:String = "";
		
		
				startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
				{
					switch (swagCounter)
		
					{
						case 0:
							FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
						case 1:
							var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
							ready.scrollFactor.set();
							ready.setGraphicSize(Std.int(ready.width * 0.5));
		
							ready.updateHitbox();
		
							ready.screenCenter();
							ready.y -= 120;
							add(ready);
							FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									ready.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
						case 2:
							var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
							set.scrollFactor.set();
								set.setGraphicSize(Std.int(set.width * 0.5));
		
							set.updateHitbox();
		
							set.screenCenter();
							set.y -= 120;
							add(set);
							FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									set.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
						case 3:
							var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
							go.scrollFactor.set();
								go.setGraphicSize(Std.int(go.width * 0.8));
		
							go.updateHitbox();
		
							go.screenCenter();
							go.y -= 120;
							add(go);
							FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									go.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
						case 4:
							PlayState.instance.tweenManager.active = true;
							unpause();
							FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);
					}
		
					swagCounter += 1;
					// generateSong('fresh');
				}, 5);
			}
			
		}
	
}
