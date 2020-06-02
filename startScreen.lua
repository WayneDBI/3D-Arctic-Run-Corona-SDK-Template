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
-- startScreen.lua
--
------------------------------------------------------------------------------------------------------------------------------------
-- 13th February July 2014
-- Version 4.0
-- Requires Corona 2013.2067 - minimum
------------------------------------------------------------------------------------------------------------------------------------

local storyboard		= require( "storyboard" )

local scene = storyboard.newScene()

---------------------------------------------------------------------------------
-- BEGINNING OF IMPLEMENTATION
---------------------------------------------------------------------------------

local image

-- level select button function
function levelSelect()
	storyboard.gotoScene( "mainGameInterface", "fade", 400  )
	return true
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	
	function Touch(event)
		if(event.phase == "began" and gameOverBool == false) then
	
		elseif(event.phase == "ended") then
			levelSelect()
		end
	end
	----------------------------------------------------------------------------------------------------
	-- Setup the Background Image
	----------------------------------------------------------------------------------------------------
	image = display.newImageRect( imagePath.."ArticRun_title.png",480,320 )
	image.x = _w/2
	image.y = _h/2
	screenGroup:insert( image )
	image:addEventListener( "touch", Touch )
	
	----------------------------------------------------------------------------------------------------
	-- Setup the Highlight bar
	----------------------------------------------------------------------------------------------------
	highlight = display.newImageRect( imagePath.."highlight.png",480,64 )
	highlight.x = _w+200
	highlight.y = _h/2
	highlight.alpha = 1.0
	highlight.rotation = -55
	screenGroup:insert( highlight )
		
	transition.to(highlight, {alpha=0.0,xScale=4.0, yScale=4.0, x=0, time=1800})				-- Swipe the Highlight across the screen	

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	storyboard.removeScene( "main" )
	storyboard.purgeScene( "mainGameInterface" )
	storyboard.removeScene( "mainGameInterface" )
	storyboard.removeAll()
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	
	print( "((destroying scene 1's view))" )
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
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

return scene