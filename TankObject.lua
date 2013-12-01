--A Tank Object CLASS
module(..., package.seeall)

local TankObject = {}
 
function TankObject.new(xLoc, yLoc, objType)
        

  -- Declare start values here, etc.
  local tankObject = display.newRect(0,0,20,20)
  tankObject:setStrokeColor(0,0,0,255);
  tankObject.strokeWidth = 8;
  tankObject:setFillColor(255,0,255,255);
  tankObject.x = xLoc;
  tankObject.y = yLoc;
  local noCollisionFilter = { categoryBits = 2, maskBits = 7 }
  physics.addBody(tankObject, {density = 200, friction = .3, bounce = .2, filter=noCollisionFilter})
  tankObject.bodyType = "dynamic"
  
  tankObject:setLinearVelocity(0,5);
  
  tankObject.type = objType;
  tankObject.name = "Drone " .. math.random(0,44);
  tankObject.nutrition = 5; 
  tankObject.mass = 1;

  local function eachFrame()
       
    -- Actions to occur on every frame
    local vx, vy = tankObject:getLinearVelocity();
    tankObject:setLinearVelocity(0, vy + .1)

    -- Check for destroy
    if (tankObject.y > display.contentHeight) then
      tankObject:destroy();
    end
            
  end
     
  -- Add the eachFrame listener      
  Runtime:addEventListener( "enterFrame", eachFrame )
  
  function tankObject:report()
    -- return this object's vitals    
  end

  
  function tankObject:destroy()
    if (tankObject ~= nil) then
      Runtime:removeEventListener("enterFrame", eachFrame);
      tankObject:removeSelf()
      tankObject = nil
    end
  end
       
  return tankObject
        
end
 
return TankObject
