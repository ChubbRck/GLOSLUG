--BodyPart.lua
--A class for a piece of the creature's body

module(..., package.seeall)

local BodyPart = {}
 
function BodyPart.new(xLoc, yLoc, depthLevel, name)
        

  -- Declare start values here, etc.
  local bodyPart = display.newImage("creature_images/" .. depthLevel .. ".png", true);
  bodyPart.x = xLoc;
  bodyPart.y = yLoc;


  local noCollisionFilter = { categoryBits = 2, maskBits = 7 }
  -- physics.addBody(bodyPart, {density = 200, friction = .3, bounce = .2, filter=noCollisionFilter})
  bodyPart.bodyType = "dynamic"
  bodyPart.name = name;
  local bufferX = {};
  local bufferY = {};

  local localTimer = 0;
  local hasStarted = false;
  local frameCounter = 1;
  local startDelay = (depthLevel-1) * 6;

  local function eachFrame()
    
    localTimer = localTimer + 1;
    if (localTimer == startDelay) then
      hasStarted = true;
    end
    if (hasStarted == true) then
      bodyPart.x = bufferX[frameCounter];
      bodyPart.y = bufferY[frameCounter];
      -- read the next location in the buffer and go there
      table.remove(bufferX, frameCounter);
      table.remove(bufferY, frameCounter);
      frameCounter = frameCounter;
    end
  
            
  end
     
  -- Add the eachFrame listener      
  Runtime:addEventListener( "enterFrame", eachFrame )
  
  function bodyPart:receive(xPos, yPos)
    -- receive locations from the creature and add them to the buffer  
    table.insert( bufferX, xPos)  
    table.insert( bufferY, yPos)
  end

  
  function bodyPart:destroy()
    if (bodyPart ~= nil) then
      Runtime:removeEventListener("enterFrame", eachFrame);
      bodyPart:removeSelf()
      bodyPart = nil
    end
  end
       
  return bodyPart
        
end
 
return BodyPart
