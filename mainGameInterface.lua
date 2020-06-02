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
-- mainGameInterface.lua
--
------------------------------------------------------------------------------------------------------------------------------------
-- 13th February July 2014
-- Version 4.0
-- Requires Corona 2013.2067 - minimum
------------------------------------------------------------------------------------------------------------------------------------

-- Collect relevant external libraries
local storyboard 	= require( "storyboard" )
local scene 		= storyboard.newScene()
--system.activate( "multitouch" )

bgObjects_Group 		= nil
player_Group			= nil
world_Group				= nil

gameOverBool			= false
levelCompleted			= false

debugON           		= false

TiltSpeed				= 3	-- How fast the LEFT and RIGHT Moves..

MaxRocksOnScreen		= 4	-- Maximum number of rocks on the screen at any one time
RocksOnScreen			= 0	-- How many Rocks are on the screen
MaxBearsOnScreen		= 2	-- Maximum number of Bears on the screen at any one time
BearsOnScreen			= 0	-- How many Bears are on the screen
MaxFishOnScreen			= 5	-- Maximum number of Fish on the screen at any one time
FishOnScreen			= 0	-- How many Fish are on the screen

moveSpeedBear			= 4900 -- (milliseconds top to bottom)
moveSpeedRocks 			= 3400 -- (milliseconds top to bottom)
moveSpeedFish 			= 3900 -- (milliseconds top to bottom)

moveSceneLeft			= false
moveSceneRight			= false

enemyBear 				= nil
playerCharacter 		= nil
playerShadow 			= nil

controlsAlpha			= 0.01	-- The LEFT and RIGHT controllers on the screen
gameScore				= 0
myhighScore				= highScore
-- create a table(array) to store the enemies, fish and rocks
-- for future performance you might consider using a single table
-- Then identify the objects within the single Array. But for clarity
-- We've separated them out for you in this template.
 enemyTable 	= {};
 fishTable 	= {};
 rocksTable 	= {};

_W 		= display.contentWidth/2
_H 		= display.contentHeight/2
_MH  	= display.contentHeight

realDeviceWidthPixels = (display.contentWidth - (display.screenOriginX * 2)) / display.contentScaleX
realDeviceHeightPixels = (display.contentHeight - (display.screenOriginY * 2)) / display.contentScaleY

-----------------------------------------------------------------
-- Setup our World/Scene Groups
-----------------------------------------------------------------
penguin_Group 		= display.newGroup()
enemy_Group 		= display.newGroup()
fish_Group 			= display.newGroup()
background_Group	= display.newGroup()
sky_Group			= display.newGroup()
buttons_Group		= display.newGroup()
score_Group			= display.newGroup()
game 				= display.newGroup()
gameOver_Group		= display.newGroup()
----------------------------------------------------------------------------------------------------
-- Extra cleanup routines
----------------------------------------------------------------------------------------------------
local coronaMetaTable = getmetatable(display.getCurrentStage())
	isDisplayObject = function(aDisplayObject)
	return (type(aDisplayObject) == "table" and getmetatable(aDisplayObject) == coronaMetaTable)
end

local function cleanGroups ( objectOrGroup )
    if(not isDisplayObject(objectOrGroup)) then return end
		if objectOrGroup.numChildren then
			-- we have a group, so first clean that out
			while objectOrGroup.numChildren > 0 do
				-- clean out the last member of the group (work from the top down!)
				cleanGroups ( objectOrGroup[objectOrGroup.numChildren])
			end
		end
			objectOrGroup:removeSelf()
    return
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
		
		audio.setVolume( musicVolume )

		-----------------------------------------------------------------
		-- Setup the various animation sequences
		-----------------------------------------------------------------
		animationSequenceData = {
		  { name = "bearHit",  frames={ 56 }, time=250, loopCount=1 },
		  { name = "bearAnimation", frames={ 1,2,3,4,5,6,7,8 }, time=650 },
		  { name = "fish1", frames={ 9,10,11,12,13,14,15,16 }, time=650 },
		  { name = "fish2", frames={ 17,18,19,20,21,22,23,24 }, time=650 },
		  { name = "fish3", frames={ 25,26,27,28,29,30,31,32 }, time=650 },
		  { name = "floor", frames={ 33,34,35,36,37,38 }, time=400 },
		  { name = "block1", frames={ 39 }, time=650, loopCount=1 },
		  { name = "block1", frames={ 40 }, time=650, loopCount=1 },
		  { name = "penguinIdle", frames={ 46 }, time=650, loopCount=1 },
		  { name = "penguinShadow", frames={ 47 }, time=650, loopCount=1 },
		  { name = "penguinFly", frames={ 42,43,44,45 }, time=650 },
		  { name = "penguinWalk", frames={ 48,49,50,51,52,53,54,55 }, time=650 }
		}

		-----------------------------------------------------------------
		-- Setup the SKY
		-----------------------------------------------------------------
		local skyBase = display.newRect( 0,0,_w,_h )
		skyBase.anchorX = 0.0		-- Graphics 2.0 Anchoring method
		skyBase.anchorY = 0.0		-- Graphics 2.0 Anchoring method
		sky_Group:insert( skyBase )

		local sky = display.newImageRect( imagePath.."obj_sky.png",560,120 )
		sky.anchorX = 0.5		-- Graphics 2.0 Anchoring method
		sky.anchorY = 0.3		-- Graphics 2.0 Anchoring method
		sky.x = _W
		sky.y = 50
		sky.yScale = 1.7
		sky_Group:insert( sky )

		-----------------------------------------------------------------
		-- Setup the animated floor effect
		-----------------------------------------------------------------
		local floor = display.newSprite( imageSheet, animationSequenceData )
		floor.anchorX = 0.5		-- Graphics 2.0 Anchoring method
		floor.anchorY = 0.5		-- Graphics 2.0 Anchoring method
		floor.x = _W
		floor.y = 250
		floor:setSequence( "floor" )
		floor:play()
		floor.xScale = 2.3
		floor.yScale = 1.2
		background_Group:insert( floor )

		-----------------------------------------------------------------
		-- Setup the BG Mountains
		-----------------------------------------------------------------
		local mountains = display.newImageRect( imagePath.."obj_mountains.png",560,109 )
		mountains.anchorX = 0.5		-- Graphics 2.0 Anchoring method
		mountains.anchorY = 0.5		-- Graphics 2.0 Anchoring method
		mountains.x = _W
		mountains.y = 98
		background_Group:insert( mountains )
		
		-----------------------------------------------------------------
		-- Setup the Player
		-----------------------------------------------------------------
		playerCharacter = display.newSprite( imageSheet, animationSequenceData )
		playerCharacter.x = _W
		playerCharacter.y = 235
		playerCharacter:setSequence( "penguinWalk" )
		playerCharacter:play()

		playerShadow = display.newSprite( imageSheet, animationSequenceData )
		playerShadow.x = playerCharacter.x
		playerShadow.y = 235+(playerCharacter.contentHeight/2)
		playerShadow:setSequence( "penguinShadow" )
		playerShadow:play()

		penguin_Group:insert( playerShadow )
		penguin_Group:insert( playerCharacter )


		-----------------------------------------------------------------
		-- Setup the TOUCH LEFT and RIGHT Controllers
		-----------------------------------------------------------------
		moveSceneLeft = display.newRect(0, 0, display.contentWidth/2, display.contentHeight)
		moveSceneLeft.anchorX = 0.0		-- Graphics 2.0 Anchoring method
		moveSceneLeft.anchorY = 0.0		-- Graphics 2.0 Anchoring method
		moveSceneLeft:setFillColor(255,255,255)
		moveSceneLeft.alpha = controlsAlpha
		moveSceneLeft.id = 1
		buttons_Group:insert( moveSceneLeft )
		
		moveSceneRight = display.newRect(0, 0, display.contentWidth/2, display.contentHeight)
		moveSceneRight.anchorX = 0.0		-- Graphics 2.0 Anchoring method
		moveSceneRight.anchorY = 0.0		-- Graphics 2.0 Anchoring method
		moveSceneRight:setFillColor(255,255,255)
		moveSceneRight.alpha = controlsAlpha
		moveSceneRight.x = moveSceneLeft.x + moveSceneLeft.width
		moveSceneRight.id = 2
		buttons_Group:insert( moveSceneRight )

		-------------------------------------------------------------------------
		-- Add Our Score and Highscore
		-------------------------------------------------------------------------
		--Score - You get a POINT for every fish you get
		myScoreText = display.newText("Score: "..gameScore, 0, 0, "HelveticaNeue-CondensedBlack", 20)
		--myScoreText:setReferencePoint(display.CenterLeftReferencePoint)
		myScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
		myScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
		myScoreText:setTextColor(0,0,0)
		myScoreText.x = 5
		myScoreText.y = 10
		myScoreText.alpha = 0.5
		buttons_Group:insert(myScoreText)

		-------------------------------------------------------------------------
		--HighScore
		-------------------------------------------------------------------------
		myHighScoreText = display.newText("Highscore: "..highScore, 0, 0, "HelveticaNeue-CondensedBlack", 20)   -- (Note we first use the GLOBALLY defined HighScore value)
		--myHighScoreText:setReferencePoint(display.CenterLeftReferencePoint)
		myHighScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
		myHighScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
		myHighScoreText:setTextColor(0,0,0)
		myHighScoreText.x = 5
		myHighScoreText.y = 32
		myHighScoreText.alpha = 0.5
		buttons_Group:insert(myHighScoreText)



		-----------------------------------------------------------------
		-- Setup the GameOver Screen
		-----------------------------------------------------------------
		gameOverScreen = display.newImageRect(imagePath.."ArticRun_gameover.png",480,320)
		gameOverScreen.x = display.contentWidth/2
		gameOverScreen.y = display.contentHeight/2
		gameOver_Group:insert( gameOverScreen )
		gameOver_Group.y = display.contentHeight*2
		gameOver_Group.alpha = 0
		-----------------------------------------------------------------
		-- Put all our objects into a GAME group - we'll rotate this Group later
		-----------------------------------------------------------------
		game:insert( background_Group )
		game:insert( enemy_Group )
		game:insert( penguin_Group )
		
		-----------------------------------------------------------------
		-- Put all the remaining NON ROTATING objects into the core game group
		-----------------------------------------------------------------
		screenGroup:insert( sky_Group )
		screenGroup:insert( game )
		screenGroup:insert( buttons_Group )
		screenGroup:insert( score_Group )
		screenGroup:insert( gameOver_Group )

		-----------------------------------------------------------------
		-- set the reference point for the GAME objects to the centre point.
		-----------------------------------------------------------------
		--game:setReferencePoint(display.CenterReferencePoint)
		game.anchorX = 0.5		-- Graphics 2.0 Anchoring method
		game.anchorY = 0.5		-- Graphics 2.0 Anchoring method

		-----------------------------------------------------------------
		--Spawn our scene Goodies to get the game started!
		-----------------------------------------------------------------
		if (gameOverBool == false) then
			spawnNewEnemyTimer = timer.performWithDelay(1000,spawnBearsTimer,0)
			spawnNewFishTimer = timer.performWithDelay(900,spawnFishTimer,0)
			spawnNewRocksTimer = timer.performWithDelay(1500,spawnRocksTimer,0)
		end	

		-----------------------------------------------------------------
		-- Start the BG Music - Looping
		-----------------------------------------------------------------
		audio.play(bgMusic, {channel=1,loops = -1})


end

		

-----------------------------------------------------------------
-- Function to spawn an object
-----------------------------------------------------------------
local function spawn(params)
    
	local object = display.newSprite( imageSheet, animationSequenceData )
	object.x = math.random(0,display.contentWidth)
	object.y = params.yPos
	object:setSequence( params.anim )
	object:play()
	object.xScale = params.xScale
	object.yScale = params.yScale
	object.destroy = false

	object.group = params.group or nil
	object.group:insert(object)		--Insert our Spawned sprite into the correct group

	object:toBack() 				-- Send the NEWLY SPAWNED enemy to the back - for depth of the 3d illusion.

    object.objTable = params.objTable				--Set the objects table to a table passed in by parameters
    object.index = #object.objTable + 1				--Automatically set the table index to be inserted into the next available table index
	
	local objectType = params.anim

	if (objectType=="bearAnimation") then
    	object.myName = "EnemyBear_" .. object.index	--Give the object a custom name
    	object.myHitName = "Bear"
		transition.to(object, {y = 220, xScale = 1.0, yScale = 1.0, time = moveSpeedBear} ) -- start the NEW bear moving down the screen
    	BearsOnScreen = BearsOnScreen + 1				-- Increment the number of bears on the screen counter
	elseif (objectType=="block1") then
    	object.myName = "block_1" .. object.index	--Give the object a custom name
    	object.myHitName = "Rock"
		transition.to(object, {y = 300, xScale = 1.0, yScale = 3.0, time = moveSpeedRocks} ) -- start the NEW bear moving down the screen
    	RocksOnScreen = RocksOnScreen + 1				-- Increment the number of bears on the screen counter
	else
    	object.myName = "fish_" .. object.index	--Give the object a custom name
    	object.myHitName = "Fish"
		transition.to(object, {y = 300, xScale = 1.0, yScale = 1.0, time = moveSpeedFish} ) -- start the NEW bear moving down the screen
    	FishOnScreen = FishOnScreen + 1				-- Increment the number of bears on the screen counter
	end
	
    object.objTable[object.index] = object			--Insert the object into the table at the specified index
    
    return object
end


--Level completed/Win code/functions
local function levelCompletedFunctionEnd()

end 


local function doGameCompleted()

end 



local function gameOverFunctionEnd()

	gameOver_Group.y = 0--display.contentHeight/2
	transition.to(gameOver_Group, {alpha=1.0, time = 4400} ) -- move penguin up the screen!

	gameOverBool = true

	--Clear out the enemies etc.
	cleanGroups(enemy_Group)
	cleanGroups(fish_Group)
	cleanGroups(buttons_Group)

end 



local function endMusic()
	--transition.to( youLoose_Group, { y = 0, time=400} )
end

-----------------------------------------------------------------
-- Game Over functions
-----------------------------------------------------------------
local function gameOverFunctionStart()
	
	gameOverBool = true
	print ("GAME OVER")
	
	audio.play(failSound)
	audio.stop(1)

	--Make Penguin fly away!
	playerCharacter:setSequence( "penguinFly" )
	playerCharacter:play()
	transition.to(playerCharacter, {y = -100, time = 900, onComplete=gameOverFunctionEnd} ) -- move penguin up the screen!
	transition.to(playerShadow, {xScale=0.1,yScale=0.1, time = 900} ) -- move penguin up the screen!

end 



-----------------------------------------------------------------
-- Hit test for Rectangular Shapes
-----------------------------------------------------------------
function hitTestObjects(obj1, obj2)
	local left = obj1.contentBounds.xMin <= obj2.contentBounds.xMin and obj1.contentBounds.xMax >= obj2.contentBounds.xMin
	local right = obj1.contentBounds.xMin >= obj2.contentBounds.xMin and obj1.contentBounds.xMin <= obj2.contentBounds.xMax
	local up = obj1.contentBounds.yMin <= obj2.contentBounds.yMin and obj1.contentBounds.yMax >= obj2.contentBounds.yMin
	local down = obj1.contentBounds.yMin >= obj2.contentBounds.yMin and obj1.contentBounds.yMin <= obj2.contentBounds.yMax
	return (left or right) and (up or down)
	
end

-----------------------------------------------------------------
-- Hit Test for Rounded Shapes
-----------------------------------------------------------------
function hitTestRoundObjects(obj1, obj2)
	local sqrt = math.sqrt
	local dx =  obj1.x - obj2.x
	local dy =  obj1.y - obj2.y
	local distance = sqrt(dx*dx + dy*dy)
		if distance < 100 then -- 50px radius
			return true
		else
			return false
		end
end



-----------------------------------------------------------------
-- The SPAWN TRIGGERS and conditions:
-----------------------------------------------------------------
-- NOTE: the trigger is in the MAIN setup INIT, with a timer running
-- every X seconds. But here we actually define the data to be spawned
-- and wether we should even do the spawning.
-----------------------------------------------------------------
function spawnBearsTimer()
	if (gameOverBool==false and BearsOnScreen <= MaxBearsOnScreen) then
		local spawns = spawn({objTable=enemyTable, group=enemy_Group, xScale=0.1, yScale=0.1, yPos=140, anim="bearAnimation"})
	end
end

function spawnFishTimer()
	if (gameOverBool==false and FishOnScreen <= MaxFishOnScreen) then
		local whichFish = math.random(1,3) -- pick a random fish for a lil pizz-az!
		local whichFishName = "fish"..whichFish
		local spawns = spawn({objTable=enemyTable, group=enemy_Group, xScale=0.1, yScale=0.1, yPos=140, anim=whichFishName})
	end
end

function spawnRocksTimer()
	if (gameOverBool==false and RocksOnScreen <= MaxRocksOnScreen) then
		local spawns = spawn({objTable=enemyTable, group=enemy_Group, xScale=0.1, yScale=0.3, yPos=140, anim="block1"})
	end
end


-----------------------------------------------------------------
-- The GAME MANAGER monitors the various conditions and checks for movement etc:
-----------------------------------------------------------------
function gameManager()
	-- only perform conditions if the Game is not over!
	if (gameOverBool == false) then
		
		if (moveSceneLeft == true) then
			for i = 1, #enemyTable do -- Iterate through the ENEMIES Table
				enemyTable[i].x = enemyTable[i].x + TiltSpeed
			end
		end
		
		if (moveSceneRight == true) then
			for i = 1, #enemyTable do -- Iterate through the ENEMIES Table
				enemyTable[i].x = enemyTable[i].x - TiltSpeed
			end
		end
		
		-- ENALE THE CODE BELOW TO LOCK THE SCREEN ROTATION
		--if (moveSceneLeft == false and moveSceneRight == false) then
		--	transition.to(game, {rotation=0, time=100} ) -- reset the rotation
		--end
		
	end
	
end


-----------------------------------------------------------------
-- Control our hero's movement
-----------------------------------------------------------------
-- Note: For this template, our hero actually remains STATIC
-- As we 'move' our hero we actually adjust the X co-ordinates of
-- all the other 'world' objects in the opposite direction.
-- The illusion is our hero is moving AWAY from the objects...
-----------------------------------------------------------------
function leftTouch(event)
	if (event.phase == 'began') then
	    print("Tilt-Left")
	    moveSceneLeft = true
		moveSceneRight = false
		transition.to(game, {rotation=-10, time=300} ) -- Rotate the GAME Group -10º
	elseif (event.phase == 'ended') then
	    moveSceneLeft = false
		moveSceneRight = false
		transition.to(game, {rotation=0, time=100} ) -- reset the rotation
	end
end

function rightTouch(event)
	if (event.phase == 'began') then
    	print("Tilt-Right")
	    moveSceneLeft = false
		moveSceneRight = true
		transition.to(game, {rotation=10, time=300} ) -- Rotate the GAME Group 10º
	elseif (event.phase == 'ended') then
	    moveSceneLeft = false
		moveSceneRight = false
		transition.to(game, {rotation=0, time=100} ) -- reset the rotation
	end
end
-----------------------------------------------------------------

-----------------------------------------------------------------
-- Update the score function
-----------------------------------------------------------------
local function updateTheScore()
		--Add a Point to our Score!
		gameScore = gameScore + 1
		if (gameScore > highScore) then
			highScore = gameScore		-- Set the Global High Score variable to the new value
		end
		
		-----------------------------------------------------------------
		-- Update Score on the screen
		-----------------------------------------------------------------
		myScoreText.text = "Score: "..gameScore
		--myScoreText:setReferencePoint(display.CenterLeftReferencePoint);
		myScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
		myScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
		myScoreText.x = 5

		-----------------------------------------------------------------
		-- Update the HighScore text on the screen
		-----------------------------------------------------------------
		myHighScoreText.text = "Highscore: "..highScore
		--myHighScoreText:setReferencePoint(display.CenterLeftReferencePoint);
		myHighScoreText.x = 5
		myHighScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
		myHighScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
end

-----------------------------------------------------------------
-- Test to see if the OBJECTS have hit our Here - and pefrom
-- various triggers based on results (BEAR, ROCKS, FISH) etc.
-----------------------------------------------------------------
local function ObjectsCollidedWithOurHero()
	
	--Only test this condition of the GameOver flag has not been set to TRUE
	if (gameOverBool == false) then

		-----------------------------------------------------------------------------------------------------------------------
		-- STEP 1
		-- Loop through all of the BEARS/ROCKS and FISH in table/array
		-----------------------------------------------------------------------------------------------------------------------
		for i = 1, #enemyTable do 						-- Iterate through the items in the Table to see if they have collided with our hero
		
			-----------------------------------------------------------------------------------------------------------------------
			if (enemyTable[i].myHitName == "Bear") then
				
				if ( enemyTable[i].contentWidth > 160 and hitTestRoundObjects(enemyTable[i], playerCharacter) ) then
					enemyTable[i]:setSequence( "bearHit" )	-- Change the BEAR to a HIT animation/sprite
					enemyTable[i]:play()					-- Make the animation play
					audio.play(bearHit)
					gameOverFunctionStart()					-- Call the Game Over function
				end
				
				if ( enemyTable[i].contentWidth > 176 ) then	-- Check to see how big the bear is.
					enemyTable[i].destroy = true 				-- Mark the bear sprite for removal.
				end
			
			elseif (enemyTable[i].myHitName == "Rock") then
			
				if ( enemyTable[i].contentWidth > 95 and hitTestRoundObjects(enemyTable[i], playerCharacter) ) then
					audio.play(hitRock)
					gameOverFunctionStart()					-- Call the Game Over function
				end
				
				if ( enemyTable[i].contentWidth > 96 ) then	-- Check to see how big the bear is.
					enemyTable[i].destroy = true 				-- Mark the bear sprite for removal.
				end
				
			elseif (enemyTable[i].myHitName == "Fish") then
			
				if ( enemyTable[i].contentWidth > 80 and enemyTable[i].destroy == false and hitTestRoundObjects(enemyTable[i], playerCharacter) ) then
					print ("SCORE")
					audio.play(getFishSound)
					enemyTable[i].destroy = true
					--gameScore = gameScore + 1
					updateTheScore() -- update the scores
				end
				
				if ( enemyTable[i].contentWidth > 99 ) then	-- Check to see how big the bear is.
					enemyTable[i].destroy = true 				-- Mark the bear sprite for removal.
				end
				
			end
			-----------------------------------------------------------------------------------------------------------------------

		end
		
		
		
		-----------------------------------------------------------------------------------------------------------------------
		-- STEP 2
		-- Check to see if any of the OBJECTS need destroying from the Screen, Game and Table
		-----------------------------------------------------------------------------------------------------------------------
		for i = #enemyTable, 1, -1 do 						-- Iterate through the BEARS Table to see if they have collided with our hero
			local object = enemyTable[i]
			if object.destroy then
				local objectName = enemyTable[i].myHitName
				local child = table.remove(enemyTable, i)	-- Remove from table
				if child ~= nil then
					child:removeSelf()
					child = nil
					if (objectName=="Bear") then
						BearsOnScreen = BearsOnScreen -1		-- Reduce the number of Bears on Screen Counter
					elseif (objectName=="Fish") then
						FishOnScreen = FishOnScreen -1		-- Reduce the number of Bears on Screen Counter
					elseif (objectName=="Rock") then
						RocksOnScreen = RocksOnScreen -1		-- Reduce the number of Bears on Screen Counter
					end
				end
			end
		end
		-----------------------------------------------------------------------------------------------------------------------
		
	end
		
end


function tapRestart(event)
	if(event.phase == "ended") then
		storyboard.gotoScene("startScreen")	--This is our main menu
		return true
	end
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	
	storyboard.purgeScene( "main" )
	storyboard.removeScene( "startScreen" )

	moveSceneLeft:addEventListener( "touch", leftTouch)
	moveSceneRight:addEventListener( "touch", rightTouch)
	gameOverScreen:addEventListener( "touch", tapRestart)

end
		
-- Called when scene is about to move offscreen:
function scene:exitScene( event )

	Runtime:removeEventListener( "enterFrame", gameManager )
	Runtime:removeEventListener("enterFrame", ObjectsCollidedWithOurHero)
	
	timer.cancel(spawnNewEnemyTimer)
	timer.cancel(spawnNewFishTimer)
	timer.cancel(spawnNewRocksTimer)
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )

end



---------------------------------------------------------------------------------
-- END OF SCENE IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

Runtime:addEventListener( "enterFrame", gameManager )
Runtime:addEventListener("enterFrame", ObjectsCollidedWithOurHero)


return scene