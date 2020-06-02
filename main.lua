------------------------------------------------------------------------------------------------------------------------------------
-- 3D Arctic Runner Corona Template
------------------------------------------------------------------------------------------------------------------------------------
-- Developed by Deep Blue Apps.com [http:www.deepbueapps.com]
------------------------------------------------------------------------------------------------------------------------------------
-- Abstract: Originally developed by Darren Spencer of Utopian Games & Deep Blue Apps
-- as a GameSalad Project. Converted to Corona (Lua) by Wayne Hawksworth of Deep Blue Apps and Deep Blue Ideas
-- A template which demonstrates a 3D technique; with objects and actors getting larger as they come towards you.
-- Recreate many forward running games like Space Harrier, Zombie Chase and Haunted Woods.
-- This template shows you how to recreate this superb effect, simply and efficiently.

------------------------------------------------------------------------------------------------------------------------------------
--
-- main.lua
--
------------------------------------------------------------------------------------------------------------------------------------
-- 13th February July 2014
-- Version 4.0
-- Requires Corona 2013.2067 - minimum
------------------------------------------------------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

-- require controller module
local storyboard 		= require "storyboard"
local physics 			= require( "physics" )
require "sprite"

_G.sprite = require "sprite"							-- Add SPRITE API for Graphics 1.0

_G._w 					= display.contentWidth  		-- Get the devices Width
_G._h 					= display.contentHeight 		-- Get the devices Height
_G.gameScore			= 0								-- The Users score
_G.highScore			= 0								-- Saved HighScore value
_G.sfxVolume			= 1								-- Default SFX Volume
_G.musicVolume			= 0.3							-- Default Music Volume
_G.imagePath			= "assets/images/"
_G.audioPath			= "assets/audio/"
_G.level				= 1								-- Global Level Select, Clean, Load, etc...

-- Enable debug by setting to [true] to see FPS and Memory usage.
local doDebug 			= false

-- Debug Data
if (doDebug) then
	local fps = require("fps")
	local performance = fps.PerformanceOutput.new();
	performance.group.x, performance.group.y = display.contentWidth/2,  270;
	performance.alpha = 0.3; -- So it doesn't get in the way of the rest of the scene
end


--Set the Music Volume
audio.setVolume( musicVolume )

function startGame()
	storyboard.gotoScene( "startScreen")	--This is our main menu
end

--Define some globally loaded assets
bearHit 		= audio.loadSound( audioPath.."BearHit.mp3" )
bgMusic			= audio.loadSound( audioPath.."Theme.mp3" )
hitRock			= audio.loadSound( audioPath.."ice.mp3" )
failSound		= audio.loadSound( audioPath.."Fail.mp3" )
getFishSound	= audio.loadSound( audioPath.."FishGrab.mp3" )


------------------------------------------------------------------------------------------------------------------------------------
-- Preload SpriteSheets
------------------------------------------------------------------------------------------------------------------------------------
sheetInfo = require("RunnerSpriteSheet")
imageSheet = graphics.newImageSheet( imagePath.."RunnerSpriteSheet.png", sheetInfo:getSheet() )

--Start Game after a short delay.
timer.performWithDelay(5, startGame )


