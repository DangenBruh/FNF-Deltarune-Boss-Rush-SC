package;

import flash.system.System;
import haxe.macro.Expr.Position;
import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'options', 'donate', 'deltarune', 'twitter', 'end'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;
	public static var firstStart:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.5.4" + nightly;
	public static var gameVer:String = "0.2.7.1";

	var magenta:FlxSprite;
	var soul:FlxSprite;
	var camFollow:FlxObject;
	var dark:FlxSprite;
	public static var finishedFunnyMove:Bool = false;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('bg');
		bg.animation.addByPrefix('idle', "bg", 24);
		bg.animation.play('idle');
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.02;
		bg.x = 166.3;
		bg.y = -26.05;
		bg.setGraphicSize(Std.int(bg.width = 949.85));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = false;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		// magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		// magenta.scrollFactor.x = 0;
		// magenta.scrollFactor.y = 0.10;
		// magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		// magenta.updateHitbox();
		// magenta.screenCenter();
		// magenta.visible = false;
		// magenta.antialiasing = true;
		// magenta.color = 0xFFfd719b;
		// add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var select = new FlxSprite(306, 144.4).loadGraphic(Paths.image('select'));
		select.updateHitbox();
		select.antialiasing = false;
		select.scrollFactor.set();
		add(select);

		soul = new FlxSprite().loadGraphic(Paths.image('soul'));
		soul.x = 377;
		soul.updateHitbox();
		soul.setGraphicSize(Std.int(bg.width = 26.3));
		soul.antialiasing = false;
		soul.scrollFactor.set();
		add(soul);

		dark = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF04021C);
		dark.scrollFactor.set();
		dark.updateHitbox();
		dark.alpha = 0.05;
		add(dark);


		var tex = Paths.getSparrowAtlas('main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite();
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " basic", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = false;

			menuItem.x = 346.8;
			switch(menuItem.ID)
			{
				case 0:
					menuItem.x = 346;
					menuItem.y = 202.9;
				case 1:
					menuItem.x = 346;
					menuItem.y = 327.8;
				case 2:
					menuItem.x = 346;
					menuItem.y = 454.45;
				case 3:
					menuItem.x = 345.9;
					menuItem.y = 591.2;
				case 4:
					menuItem.x = 345.9;
					menuItem.y = 645.7;
				case 5:
					menuItem.x = 763.1;
					menuItem.y = 586.75;
				case 6:
					menuItem.x = 763.1;
					menuItem.y = 645.7;
			}
			// if (firstStart)
			// 	FlxTween.tween(menuItem,{y: 60 + (i * 160)},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
			// 		{ 
			// 			finishedFunnyMove = true; 
			// 			changeItem();
			// 		}});
			// else
			// 	menuItem.y = 60 + (i * 160);
		}

		firstStart = false;

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer +  (Main.watermarks ? " FNF - " + kadeEngineVer + " Kade Engine" : ""), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("determination.otf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		// if(dark.alpha = 0.1)
		// 	FlxTween.tween(dark, {alpha: 0.2}, 5);
		// else if(dark.alpha = 0.2)
		// 	FlxTween.tween(dark, {alpha: 0.1}, 5);
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}
			}

			if (FlxG.keys.justPressed.UP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.DOWN)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
					fancyOpenURL("https://ninja-muffin24.itch.io/funkin");
				else if (optionShit[curSelected] == 'deltarune')
					fancyOpenURL("https://deltarune.com");
				else if (optionShit[curSelected] == 'twitter')
					fancyOpenURL("https://twitter.com/home"); //we didnt make an account yet lol
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					
					// if (FlxG.save.data.flashing)
					// 	FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 1.3, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								FlxG.camera.fade(FlxColor.BLACK, 1, false, function(){
									goToState();
								});
							});
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			// spr.screenCenter(X);
		});
	}
	
	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");
			case 'freeplay':
				FlxG.switchState(new FreeplayState());

				trace("Freeplay Menu Selected");

			case 'options':
				FlxG.switchState(new OptionsMenu());
			case 'end':
				System.exit(0);
		}
	}

	function changeItem(huh:Int = 0)
	{
		// if (finishedFunnyMove)
		// {
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		switch(curSelected)
		{
			case 0:
				FlxTween.tween(soul,{y: 252, alpha: 1}, 0.1, {ease: FlxEase.quadInOut});
			case 1:
				FlxTween.tween(soul,{y: 382.35, alpha: 1}, 0.1, {ease: FlxEase.quadInOut});
			case 2:
				FlxTween.tween(soul,{y: 502, alpha: 1}, 0.1, {ease: FlxEase.quadInOut});
			case 3,4,5,6:
				FlxTween.tween(soul, {y: 602, alpha: 0}, 0.1, {ease: FlxEase.quadInOut});
		}
		// }
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.alpha = 0.5;

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				spr.alpha = 1;
				if (curSelected <= 2)
					FlxTween.tween(camFollow, {x: spr.getGraphicMidpoint().x, y: spr.getGraphicMidpoint().y}, 0.4, {ease: FlxEase.quadInOut});
				// camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
