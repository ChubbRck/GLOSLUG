---------- Declare libraries and globals ----------
local physics = require "physics"
local sprite = require "sprite";
local preference = require "preference"

local TankObject = require("TankObject") 
local BodyPart = require("BodyPart")
physics.start();
physics.setGravity(0,0);
-- physics.setDrawMode('hybrid')
system.activate("multitouch");
display.setStatusBar( display.HiddenStatusBar )

local sampleTable = {}
local systemTimer = 0;

local h = display.contentHeight
local w = display.contentWidth
local noCollisionFilter = { categoryBits = 1, maskBits = 2 }
local wallFilter = { categoryBits = 2, maskBits = 7 }

local bg = display.newRect(0,0,w,h);
bg:setFillColor(40,40,155)

local head = display.newImage("creature_images/1.png", true);
-- local neck = display.newImage("creature_images/2.png", true);
-- local body = display.newImage("creature_images/3.png", true);
-- local rear = display.newImage("creature_images/4.png", true);
-- local tail = display.newImage("creature_images/5.png", true);


local tail = BodyPart.new(0, 0, 10, "tail")
local rear6 = BodyPart.new(0, 0, 9, "rear")
local rear5 = BodyPart.new(0, 0, 8, "rear")
local rear4 = BodyPart.new(0, 0, 7, "rear")
local rear3 = BodyPart.new(0, 0, 6, "rear")
local rear2 = BodyPart.new(0, 0, 5, "rear")
local rear = BodyPart.new(0, 0, 4, "rear")
local body = BodyPart.new(0, 0, 3, "body")
local neck = BodyPart.new(0, 0, 2, "neck")
head.name = "head"
neck.name = "neck"
body.name = "body";
rear.name = "rear"
tail.name = "tail";

head:setReferencePoint(display.CenterReferencePoint);
body:setReferencePoint(display.CenterReferencePoint);
tail:setReferencePoint(display.CenterReferencePoint);
neck:setReferencePoint(display.CenterReferencePoint);
rear:setReferencePoint(display.CenterReferencePoint);
rear2:setReferencePoint(display.CenterReferencePoint);
rear3:setReferencePoint(display.CenterReferencePoint);
rear4:setReferencePoint(display.CenterReferencePoint);
rear5:setReferencePoint(display.CenterReferencePoint);
rear6:setReferencePoint(display.CenterReferencePoint);

local chunksPassed = 1;
local updateDuration = 10;
local hasTarget = false;
local targetReached = false;
local targetX;
local targetY;
local timePerPoll = 2;
local pollTimer = 0;
local desireThreshold = .20;
local userTouching = false;
local fingerLocX = 0;
local fingerLocY = 0;
local tankObjectsPresent;
local followMode = false;
local followModeTimer = 0;
local followModeTimerNoise;
local timeAtLastRandomMovement = 0;
local timeSinceLastRandomMovement = 0;


local leftTankWall = display.newRect(0,0,10,h);
leftTankWall:setFillColor(255,0,0)
physics.addBody(leftTankWall, {density = 10, friction = .3, bounce = .2})
leftTankWall.bodyType = "static"

local rightTankWall = display.newRect(w-10,0,10,h);
rightTankWall:setFillColor(255,0,0)
physics.addBody(rightTankWall, {density = 10, friction = .3, bounce = .2})
rightTankWall.bodyType = "static"

local topTankWall = display.newRect(0,0,w,10);
topTankWall:setFillColor(255,0,0)
physics.addBody(topTankWall, {density = 10, friction = .3, bounce = .2})
topTankWall.bodyType = "static"

local bottomTankWall = display.newRect(0,h-10,w,10);
bottomTankWall:setFillColor(255,0,0)
physics.addBody(bottomTankWall, {density = 10, friction = .3, bounce = .2})
bottomTankWall.bodyType = "static"

physics.addBody(head, {density = 1, friction = .3, bounce = .2})
physics.addBody(body, {density = 1, friction = .3, bounce = .2, filter=noCollisionFilter})
physics.addBody(tail, {density = 1, friction = .3, bounce = .2, filter=noCollisionFilter})
physics.addBody(neck, {density = 1, friction = .3, bounce = .2, filter=noCollisionFilter})
physics.addBody(rear, {density = 1, friction = .3, bounce = .2, filter=noCollisionFilter})
head.linearDamping = 0
body.linearDamping = 0
tail.linearDamping = 0
neck.linearDamping = 0
rear.linearDamping = 0
head.bodyType = "dynamic" 
body.bodyType = "dynamic" 
tail.bodyType = "dynamic" 
neck.bodyType = "dynamic" 
rear.bodyType = "dynamic" 

-- head.isSensor = "false"
-- body.isSensor = "true"
-- tail.isSensor = "true"
-- neck.isSensor = "true"
-- rear.isSensor = "true"

head.x, body.x, tail.x, neck.x, rear.x = w/2,w/2,w/2,w/2,w/2
head.y, body.y, tail.y, neck.y, rear.y = h/2,h/2,h/2,h/2,h/2

local tankScreen = display.newGroup();
local theCreature = {};
local tankObjects = display.newGroup();
theCreature.name = "Billy"
-- theCreature:setReferencePoint(display.CenterReferencePoint);
-- theCreature.x = 0;
-- theCreature.y = 0;

-- theCreature:insert(tail);
-- theCreature:insert(rear);
-- theCreature:insert(body);
-- theCreature:insert(neck);
-- theCreature:insert(head);
theCreature = {tail, rear6, rear5, rear4, rear3, rear2, rear, body, neck}


 tankScreen:insert(bg);
-- tankScreen:insert(theCreature);
tankScreen:insert(tankObjects);


tankScreen:insert(tail)
tankScreen:insert(rear6)
tankScreen:insert(rear5)
tankScreen:insert(rear4)
tankScreen:insert(rear3)
tankScreen:insert(rear2)
tankScreen:insert(rear)
tankScreen:insert(body)
tankScreen:insert(neck)
tankScreen:insert(head)

tankScreen:insert(leftTankWall)
tankScreen:insert(topTankWall)
tankScreen:insert(rightTankWall)
tankScreen:insert(bottomTankWall)
-- sampleSFX = audio.loadSound("sample.wav");

---------- END Declare libraries and globals ----------

function modifyTrait(trait, operation, value)
    if (operation == "add") then
        trait = trait + value;
    end

    if (operation == "subtract") then
        trait = trait - value;
      --  print("trait is" .. trait);
    end

    --clamp values;
    if (trait < 0) then
        trait = 0;
    end
    if (trait > 100) then
        trait = 100
    end

    return trait;
end

function calculateShade() 
-- Set bg shade depending on time of day
    local hour = tonumber(os.date( "%H" ));
    
    if (hour <= 12) then
        bg.alpha = hour/12
    else
        local relativeHour = hour - 12;
        bg.alpha = 1-(relativeHour/12)
    end
end

local function saveAndSignOff() -- change this to take an argument

    local signOffTime = os.time();
    preference.save{lastVisit=signOffTime}
    preference.save{traits=theCreature.traits}
end

local function loadAndRecalculateState()
    calculateShade(); 

    local lastVisit = preference.getValue("lastVisit")
    
    if (lastVisit == nil) then
        lastVisit = os.time();
        print("NO LAST VISIT DATA!");


    end

    print("total number of seconds since last visit is " .. lastVisit - os.time())
    local secsSinceLastVisit = os.time() - lastVisit;
    local minsSinceLastVisit = secsSinceLastVisit / 60;
    local hoursSinceLastVisit = minsSinceLastVisit / 60;
    print ("it has been " .. hoursSinceLastVisit .. " hours since your last visit")

    -- load the saved traits

    -- modify them based on hours since last visit;
    local traits = preference.getValue("traits")

    theCreature.hunger = traits[1];
    theCreature.happiness = traits[2];
    theCreature.alertness = traits[3];
    theCreature.weight = traits[4];
    theCreature.strength = traits[5];

   

    theCreature.hunger = modifyTrait(theCreature.hunger, "add", 1*hoursSinceLastVisit);
    -- check if lights were turned off
    theCreature.alertness = modifyTrait(theCreature.alertness, "subtract", 1*hoursSinceLastVisit);
    -- end check
    theCreature.happiness = modifyTrait(theCreature.happiness, "subtract", 1*hoursSinceLastVisit);

    theCreature.traits = {(theCreature.hunger), theCreature.happiness, theCreature.alertness, theCreature.weight, theCreature.strength} 
    --recalculate overall health here

    print("theCreature.hunger is " .. theCreature.hunger)
    print("theCreature.happiness is " .. theCreature.happiness)
    print("theCreature.alertness is " .. theCreature.alertness)
    print("theCreature.weight is " .. theCreature.weight)
    print("theCreature.strength is " .. theCreature.strength)
    

end

---------- INIT GAME FUNCTION. (Run every time game is launched and reset) ----------

function initializeGame()
    
    -- calculateShade();
    
    
    -- -- reset variables here, set things into motion
    -- -- In the future, load the creature's stats/variables. For now, just initialize them
    -- theCreature.hunger = 50;
    -- theCreature.happiness = 50;
    -- theCreature.alertness = 50;

    -- -- 'second tier traits?'
    -- theCreature.weight = 50;
    -- theCreature.strength = 50;

    -- -- health is an average of all other values. Desire is a temporary thing?
    -- theCreature.health = 50;
    -- theCreature.desire = 0;

    -- theCreature.traits = {theCreature.hunger, theCreature.happiness, theCreature.alertness, theCreature.weight, theCreature.strength}
 

    -- -- Check time since last visit 
    -- local lastVisit = preference.getValue("lastVisit")
    -- if (lastVisit == nil) then
    --     lastVisit = os.time();
    -- end
    -- print("total number of seconds since last visit is " .. lastVisit - os.time())
    -- local secsSinceLastVisit = os.time() - lastVisit;
    -- local minsSinceLastVisit = secsSinceLastVisit / 60;
    -- local hoursSinceLastVisit = minsSinceLastVisit / 60;
    -- print ("it has been " .. hoursSinceLastVisit .. " hours since your last visit")
    -- preference.save{traits={50,50,50,50,50,50,50,50}}

    -- NEED A HANDLER HERE FOR FIRST TIME (or put it in loadandrecalculate?)
    loadAndRecalculateState();
end

---------- END INIT GAME FUNCTION ----------

---------- RUN TITLE SCREEN (first function that gets run) -----------

local function runTitleScreen()

    --display title screen graphics, create start buttons, etc., launch animations
    
   -- local function startButton:tap( event ) 
        
        --remove title screen group
        --remove self, etc.
        initializeGame()
    --end
    
end

---------- END TITLE SCREEN FUNCTION ----------

-- 
----------APP BEGINS HERE----------
--

runTitleScreen();

--
----------END APP START----------
--


--
----------AUXILLIARY FUNCTIONS---------- 
--



function calculateDesire(typeOfTarget, proximity)
  --  print(typeOfTarget);
    local desire = 0;
    local proximityFactor = (1 / proximity); 
    if (typeOfTarget == "userTouch") then

    end

    if (typeOfTarget == "food") then
     --   print("hunger is " .. theCreature.hunger)
        desire = (theCreature.hunger / 100) + proximityFactor;

        
    end

    return desire;
end

function moveToward (xLoc, yLoc, optionalModifier)
    
    if (optionalModifier == nil) then
        optionalModifier = 1;
    end
    local distX = (xLoc - head.x);
    local distY = (yLoc - head.y);
    
    -- Get the angle the creature should travel by taking inverse tangent of the y 'distance' over the x 'distance' (TOA = Tangent: Opposite over Adjacent!)
    
    local angle = math.atan2(distY,distX)
    
    -- Later, change this into a variable based on the creature
    local constantForce = (50 + ((theCreature.strength/100) * 100)) * optionalModifier; 
    
    -- Normalize the force using cosine and sine and multiplying by the desired constant force. Also, multiply by multX and multY, my hacky 'direction' handlers.
    
    local xPower = math.cos(angle)*constantForce
    local yPower = math.sin(angle)*constantForce


            --Turn off damping
           head.linearDamping = 0.5
           
           head:setLinearVelocity(xPower,yPower)

   -- cycle through objects in the group 
   
   -- apply a force to one
   -- delay
   -- repeat

end

function manageTouch(event)
    local startTime;
    local startX;
    local startY;

    if (event.phase == "began") then
        userTouching =true;
        if (tankObjectsPresent == false ) then
        local chance = math.random(100);
        if (chance <= 50) then
            followMode = true;
            followModeTimerNoise = math.random(90);
        end
    end
      -- Get the absolute value of the distance between where the touch ended and where it began
    -- local to = TankObject.new(event.x, event.y, "food")
    -- tankObjects:insert( to );


        
    end
    if (event.phase == "moved") then
        -- random chance for entering follow mod

        fingerLocX = event.x;
        fingerLocY = event.y;
    end
    if (event.phase == "ended") then
        userTouching = false
        followMode = false;
        followModeTimer = 0;
    end

end

local function updatePeriodically()
-- print(system.getTimer());
    
    calculateShade(); 
    local currentTime = math.round(system.getTimer() / 1000);
   
    if (currentTime % updateDuration == 0) then
       -- print("update duration has passed")
       local dupeCheck;
       
            dupeCheck = updateDuration * chunksPassed;
        
        -- print("dupe check is " .. dupeCheck);
        if (currentTime == dupeCheck) then
            -- print("15 minutes have passed")
            chunksPassed = chunksPassed + 1;
            
            -- update variables here
            theCreature.hunger = modifyTrait(theCreature.hunger, "add", 5);
            theCreature.alertness = modifyTrait(theCreature.alertness, "add", 1);
            theCreature.happiness = modifyTrait(theCreature.happiness, "subtract", 1);

            --secondary traits
            local hungerFactor = ((theCreature.hunger - 50) / 50) * 5;
            local theSign;
            if (hungerFactor < 0) then
                theSign = "add"
            else
                theSign = "subtract"
            end
            theCreature.weight = modifyTrait(theCreature.weight, theSign, 2);

            if(math.abs(hungerFactor) < 1) then
                theCreature.strength = modifyTrait(theCreature.strength, "add", 5);
            end

            -- health is an average of all the 'traits'
            local tot = 0;

            theCreature.tempTraits = {(100 -theCreature.hunger), theCreature.happiness, theCreature.alertness, theCreature.weight, theCreature.strength}
            for i=1,#theCreature.tempTraits do
                local trait = theCreature.tempTraits[i];
                --print( "trait number ".. i .. " is " .. trait )
                tot = tot + trait;
            end   
            local average = tot / #theCreature.tempTraits;
            --print("average is now " .. average)
            theCreature.health = average;

            -- save traits to disk
            theCreature.traits = {(theCreature.hunger), theCreature.happiness, theCreature.alertness, theCreature.weight, theCreature.strength}
            saveAndSignOff();
         
        end
        
    end

end
local function runMain()

    -- tankScreen.x = tankScreen.x + 1;
     local currentLocX = head.x;
     local currentLocY = head.y;

     systemTimer = systemTimer + 1;
     if (systemTimer == 1) then
     for i=1,#theCreature,1 do
         
        
            local child = theCreature[i]
            -- print(child.name)

            --Turn off damping
            child.linearDamping = 0.5
           
            -- local myClosure = function() child.x = currentLocX; child.y = currentLocY; end
            -- whichOne = #theCreature - i;
            -- timer1 = timer.performWithDelay( 200*whichOne, myClosure )

            child:receive(head.x, head.y);
        

    end
    systemTimer = 0;
end

    -- Check every period (15 minutes is default) and update some variables
    updatePeriodically();
    -- every 2 seconds, poll all onscreen objects and find out which is most desirable given the creature's current state
    pollTimer = pollTimer + 1;
    if (tankObjects.numChildren > 0) then
        tankObjectsPresent = true;
    else
        tankObjectsPresent = false;
    end
    --print(tankObjectsPresent)
    if (pollTimer == timePerPoll * 30) then

        local bestTargetX = nil;
        local bestTargetY = nil;
        local bestDesire = 0;
        local bestName = "none";

        -- cycle through all group objects onscreen
     

        for i=tankObjects.numChildren,1,-1 do
            local child = tankObjects[i]
           -- print(child.type)
            -- what factors are useful for determining desire? proximity
            local proximity = math.sqrt((head.x-child.x)^2+(head.y-child.y)^2)
         --   print(proximity)
            
            --get the desire
           -- print(child.type)
            local currentDesire = calculateDesire(child.type, proximity)
           -- print ("currentDesire is " .. currentDesire);
            if (currentDesire > bestDesire) then
                bestDesire = currentDesire 
                bestTargetX = child.x;
                bestTargetY = child.y;
                bestName = child.name;
            end
        end

       -- print(bestName .. " is the most desirable, right now.");
        -- Does it meat the desirability threshold? 
        if (bestDesire > desireThreshold) then
            -- Move toward the most desired!
            moveToward(bestTargetX, bestTargetY);
        end

         pollTimer = 0;
         -- generate a new time for next poll based on alertness and a little random noise
         local alertnessFactor = (theCreature.alertness / 100)

         timePerPoll = 2 + math.random(4) - (3*alertnessFactor);
        -- print ("timePerPoll is now" .. timePerPoll)


    end
    
    if (userTouching and tankObjectsPresent == false) then
        -- a random chance of moving toward the user's finger
        -- local chance = math.random(100);
        -- local alertnessFactor = (theCreature.alertness/100) * 5;
        -- if (chance < 10 + alertnessFactor) then
        --      moveToward(fingerLocX, fingerLocY);
        -- end
      --  print(followMode);
        if (followMode) then
            followModeTimer = followModeTimer + 1;
            if (followModeTimer > (30 * 4) + followModeTimerNoise) then
                followMode = false;
                followModeTimer = 0;
            end
            -- Target has to be a little far away...
            local proximity = math.sqrt((head.x-fingerLocX)^2+(head.y-fingerLocY)^2)
              moveToward(fingerLocX, fingerLocY, .8);
            if (proximity < 10) then
              
                followMode = false;
                followModeTimer = 0;
                theCreature.happiness = modifyTrait(theCreature.happiness, "add", 1);

                
            end
        end
            -- random chance for a random destination
           

        else if (userTouching == false and tankObjectsPresent == false) then
             local factor = theCreature.alertness / 10;
            local chance = math.random(200)
          --  print (chance)
            if (chance < factor) then
                timeSinceLastRandomMovement = os.time() - timeAtLastRandomMovement;
                if (timeSinceLastRandomMovement > 3) then
                 --   print ("random destination")
                    randX = math.random(w);
                    randY = math.random(h);
                    local randomFactor = math.random(10) / 10;
                    moveToward(randX, randY, randomFactor);
                    timeAtLastRandomMovement = os.time();

                end
            end

end
       
    end
    -- Does the creature have a target? If so, check if he is there yet
    if (hasTarget) then
         
         -- There must be a better way to do this...
         local distX = math.abs(targetX - head.x);
         local distY = math.abs(targetY - head.y);
         --print(distX);
         if (distX < 10 and distY < 10) then
      --      print("target reached!")
            targetReached = true;
         end

        if (targetReached) then
            head.linearDamping = 1
            body.linearDamping = 1
            tail.linearDamping = 1
            neck.linearDamping = 1
            rear.linearDamping = 1;

            hasTarget = false;
            targetReached = false;
        end
    else 
        -- random chance to find a target
        local chance = math.random(100);
      --  print(chance);
        local chanceThreshold = (theCreature.alertness / 100) * 5;
        if (chance < chanceThreshold) then
           -- print("go!")
            -- let's apply a random target;
            targetReached = false;
            hasTarget = true;
            targetX = math.random(w);
            targetY = math.random(h);
        end    


    end
end
local function onCollision( self, event )
           if ( event.phase == "began" ) then
              --  print("collision began")
                if (event.other.type == "food") then
                theCreature.hunger = modifyTrait(theCreature.hunger, "subtract", event.other.nutrition); --change this to be a 'object value'
                theCreature.weight = modifyTrait(theCreature.weight, "add", event.other.mass);  --ooh, change this to a value, different foods are healthier, etc.
                 event.other:destroy();
                end
               
           end

        end

local function memCheck()
    -- local result = audio.usedChannels
    -- print(result);
    -- local mem = collectgarbage("count")
    -- print(mem);
    -- print(system.getInfo( "textureMemoryUse" ))
end




local function onSystemEvent( event )

    if (event.type == "applicationSuspend") then
       saveAndSignOff();
    end

    if (event.type == "applicationResume") then
        loadAndRecalculateState();

    end

    if (event.type == "applicationExit") then
        saveAndSignOff();
    end

end

--
----------END AUXILLIARY FUNCTIONS---------
--

--
----------ADD GLOBAL LISTENERS---------
--
Runtime:addEventListener("touch", manageTouch)
Runtime:addEventListener("enterFrame", runMain);
head.collision = onCollision
head:addEventListener( "collision", head )
Runtime:addEventListener( "system", onSystemEvent )
--Runtime:addEventListener("enterFrame", memCheck);

-- 
----------END ADD GLOBAL LISTENERS
--