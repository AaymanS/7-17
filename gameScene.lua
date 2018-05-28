-----------------------------------------------------------------------------------------
-- Created by: Aayman Shameem
-- Created on: May 28, 2018
-- 
-- This code will show the user a Robot jumping and shooting (not at the same time)
-----------------------------------------------------------------------------------------

-- game scene

-- place all the require statements here
local composer = require( "composer" )
local physics = require("physics")
local json = require( "json" )
local tiled = require( "com.ponywolf.ponytiled" )
 
local scene = composer.newScene()

-- you need these to exist the entire scene
-- this is called the forward reference
local map = nil
local robot = nil
local rightArrow = nil
local jumpButton = nil
local shootButton = nil
local playerTomatoes = {}

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function onRightArrowTouch( event )
    if ( event.phase == "began" ) then
        if robot.sequence ~= "walk" then
            robot.sequence = "walk"
            robot:setSequence( "walk" )
            robot:play()
        end

    elseif ( event.phase == "ended" ) then
        if robot.sequence ~= "idle" then
            robot.sequence = "idle"
            robot:setSequence( "idle" )
            robot:play()
        end
    end
    return true
end

local function onJumpButtonTouch( event )
    if ( event.phase == "ended" ) then
            robot:setLinearVelocity( 0, -750 )
            robot:setSequence( "jump" )
            robot.sequence = "jump"
            
            robot:play()

    elseif ( event.phase == "ended" ) then
        if robot.sequence ~= "idle" then
            robot.sequence = "idle"
            robot:setSequence( "idle" )
            robot:play()
        end
    end
    return true
end


local robotShoot = function( event )
    -- after 1 second go back to idle
    robot.sequence = "idle"
    robot:setSequence( "idle" )
    robot:play()
end


local checkPlayerTomatoisOutOfBounds = function ( event )
        -- check if any tomatoes are out of bounds
    local tomatoCounter

    if #playerTomatoes > 0 then
        for tomatoCounter = #playerTomatoes, 1, -1 do
            if playerTomatoes[ tomatoCounter ].x > display.contentWidth * 2 then
                playerTomatoes[ tomatoCounter ]:removeSelf()
                playerTomatoes[ tomatoCounter ] = nil
                table.remove( playerTomatoes, tomatoCounter )
                print( "remove tomatoes" )
            end
        end
    end
end


local function onShootButtonTouch( event )
    if ( event.phase == "began" ) then
        if robot.sequence ~= "shoot" then
            robot.sequence = "shoot" 
            robot:setSequence( "shoot" )

            --[[elseif robotVelocityY > 0 then
                robot.sequence = "jump and shoot"
                robot:setSequence( "jump and shoot" )]]

            robot:play()
            timer.performWithDelay( 800, robotShoot )

            -- make a tomato appear
            local tomatoThing = display.newImage( "./assets/sprites/items/KawaiiTomato.png" )
            tomatoThing.x = robot.x
            tomatoThing.y = robot.y 
            physics.addBody( tomatoThing, "dynamic" )
            -- Make the object a "bullet" type object
            tomatoThing.isBullet = true
            tomatoThing.isFixedRotation = true
            tomatoThing.gravityScale = 0
            tomatoThing.id = "tomato with face"
            tomatoThing:setLinearVelocity( 1500, 0 )

            table.insert( playerTomatoes, tomatoThing )
            print( "# of bullet: " .. tostring( #playerTomatoes ) )
        end

    elseif ( event.phase == "ended" ) then

    end
    return true
end

local moveRobot = function( event )

    if robot.sequence == "walk" then
        transition.moveBy( robot, {
            x = 10,
            y = 0,
            time = 0
            } )
    end

    if robot.sequence == "jump" then

        -- can also check if the robot has landed from a jump
        local robotVelocityX, robotVelocityY = robot:getLinearVelocity()

        if robotVelocityY == 0 then
            -- the robot is currently not jumping
            -- it was jumping so set to idle
            robot.sequence = "idle"
            robot:setSequence( "idle" )
            robot:play()
        end

    end
end

 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- start physics
    physics.start()
    physics.setGravity(0, 32)
    physics.setDrawMode( "normal" )


    local filename = "assets/maps/level13.json"
    local mapData = json.decodeFile( system.pathForFile( filename, system.ResourceDirectory ) ) 
    map = tiled.new( mapData, "assets/maps" )


    --our character
    local sheetOptionsIdle = require( "assets.spritesheets.robot.robotIdle" )
    local sheetIdleRobot = graphics.newImageSheet( "./assets/spritesheets/robot/robotIdle.png", sheetOptionsIdle:getSheet() )

    local sheetOptionsWalk = require( "assets.spritesheets.robot.robotRun" )
    local sheetWalkingRobot = graphics.newImageSheet( "./assets/spritesheets/robot/robotRun.png", sheetOptionsWalk:getSheet() )

    local sheetOptionsShoot = require( "assets.spritesheets.robot.robotShoot" )
    local sheetShootRobot = graphics.newImageSheet( "./assets/spritesheets/robot/robotShoot.png", sheetOptionsShoot:getSheet() )

    local sheetOptionsJump = require( "assets.spritesheets.robot.robotJump" )
    local sheetJumpRobot = graphics.newImageSheet( "./assets/spritesheets/robot/robotJump.png", sheetOptionsJump:getSheet() )

    local sheetOptionsJumpShoot = require( "assets.spritesheets.robot.robotJumpShoot" )
    local sheetJumpShootRobot = graphics.newImageSheet( "./assets/spritesheets/robot/robotJumpShoot.png", sheetOptionsJump:getSheet() )

    --sequences table
    local sequence_data = {
    -- consecutive frames sequence
        {

            name = "idle",
            start = 1,
            count = 10,
            time = 800,
            loopCount = 0,
            sheet = sheetIdleRobot
        },
        {

            name = "walk",
            start = 1,
            count = 10,
            time = 1000,
            loopCount = 1,
            sheet = sheetWalkingRobot
        },
        {

            name = "shoot",
            start = 1,
            count = 10,
            time = 800,
            loopCount = 0,
            sheet = sheetShootRobot
        },
        {

            name = "jump and shoot",
            start = 1,
            count = 10,
            time = 800,
            loopCount = 0,
            sheet = sheetJumpShootRobot
        },
        {

            name = "jump",
            start = 1,
            count = 10,
            time = 1000,
            loopCount = 1,
            sheet = sheetJumpRobot
        }
    }

    robot = display.newSprite( sheetIdleRobot, sequence_data )
    -- Add physics
    physics.addBody( robot, "dynamic", { density = 3, bounce = 0, friction = 1.0 } )
    robot.isFixedRotation = true
    robot.x = display.contentWidth * .5
    robot.y = 0
    robot:setSequence( "idle" )
    robot.sequence = "idle"
    robot:play()

    rightArrow = display.newImage( "./assets/sprites/rightButton.png" )
    rightArrow.x = 260
    rightArrow.y = display.contentHeight - 177
    rightArrow.id = "right arrow"
    rightArrow.alpha = 0.5

    jumpButton = display.newImage( "./assets/sprites/jumpButton.png" )
    jumpButton.x = display.contentWidth - 80
    jumpButton.y = display.contentHeight - 80
    jumpButton.id = "jump button"
    jumpButton.alpha = 0.5

    shootButton = display.newImage( "./assets/sprites/jumpButton.png" )
    shootButton.x = display.contentWidth - 277
    shootButton.y = display.contentHeight - 80
    shootButton.id = "shoot button"
    shootButton.alpha = 0.5

    sceneGroup:insert( map )
    sceneGroup:insert( robot )
    sceneGroup:insert( rightArrow )
    sceneGroup:insert( jumpButton )
    sceneGroup:insert( shootButton )
    
 
    end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- add in code to check character movement
        sceneGroup:insert( rightArrow )

        rightArrow:addEventListener( "touch", onRightArrowTouch )
        jumpButton:addEventListener( "touch", onJumpButtonTouch )
        shootButton:addEventListener( "touch", onShootButtonTouch )  
        


 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        Runtime:addEventListener( "enterFrame", moveRobot )
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

        -- good practise to remove every event listener you create
        rightArrow:removeEventListener( "touch", onRightArrowTouch )
        jumpButton:addEventListener( "touch", onJumpButtonTouch )
        shootButton:addEventListener( "touch", onShootButtonTouch )    
        Runtime:removeEventListener( "enterFrame", moveRobot )
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene
