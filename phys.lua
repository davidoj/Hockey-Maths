-- Collision detection.

require "math"

-- function ObjectCollision(obj1,obj2)
--    return obj1.x < obj2.x+obj2.w and
--       obj2.x < obj1.x+obj1.w and
--       obj1.y < obj2.y+obj2.h and
--       obj2.y < obj1.y+obj1.h
-- end

-- function WallCollision(obj1,borders)
--    if obj1.x+obj1.w >= borders.xMax or
--       obj1.x < borders.xMin then
--          return 0
--    elseif  obj1.y+obj1.h >= borders.yMax or
--       obj1.y < borders.yMin then
--          return 3.14/2
--    end
--    return nil
-- end

-- -- Returns bool, bool indicating whether x and/or y axes of the objects overlap
-- function AxisOverlap(obj1,obj2)
--    local xv, yv = 0, 0
--    xv = (obj1.x+obj1.w < obj2.x and obj2.x + obj2.w < obj1.x)
--    yv = (obj1.y+obj2.y < obj2.y and obj2.y + obj2.h < obj1.y)
--    return xv, yv
-- end


-- Checks for collision between reactive and 'static' object, returns index of face of static object
-- first collided with (1-4 starting from left)
-- Or a negative collision time if no collision

function ObjectCollision(objR,objS)
   --local minT = math.huge
   local ux, uy = objS.xdot-objR.xdot, objS.ydot-objR.ydot
   local dx1, dx2 = objS.x-objR.x-objR.w, objS.x+objS.w-objR.x
   local dy1, dy2 = objS.y-objR.y-objR.h, objS.y+objS.h-objR.y
   local tx1,tx2,ty1,ty2 =  -dx1/ux,-dx2/ux, -dy1/uy,-dy2/uy
   local minx,maxx,miny,maxy = math.min(tx1,tx2), math.max(tx1,tx2), math.min(ty1,ty2), math.max(ty1,ty2)
   maxMin = math.max(minx,miny)
   minMax = math.min(maxx,maxy)
  
   if maxMin<0 then 
      return maxMin, 0 
   end
   if maxMin < minMax then  -- collision
      for i, var in ipairs {tx1,ty1,tx2,ty2} do
         if var == maxMin and var >= 0 then
            --minT = var
            cId = i
         end
      end
   else return -1, 0
   end

   return maxMin, cId
end
-- Converts numeric collision ID to collision code
function cId2ccode(cId)
   local c = {0,0}
   if cId == 1 then c = {-1,0}
   elseif cId == 2 then c = {0,-1}
   elseif cId == 3 then c = {1,0}
   elseif cId == 4 then c =  {0,1}
   end
   return c
end

function WallCollision(obj,borders)
   local c = {0,0}
   if obj.x < borders.xMin then c[1] = 1
   elseif obj.x+obj.w >= borders.xMax then c[1] = -1
   end
   if obj.y < borders.yMin then c[2] = 1
   elseif obj.y + obj.h >= borders.yMax then c[2] = -1
   end
   return c
end

-- Reflects object from vertical or horizontal surface

function ReflectFromSurface(obj,ccode)
   if ccode[1]~=0 then
      obj.xdot = math.abs(obj.xdot)*ccode[1]
   end
   if ccode[2]~=0 then
      obj.ydot = math.abs(obj.ydot)*ccode[2]
   end
end

-- What to do with the ball when it collides with something flat at angle orient


-- function OnCollision(ball,wall_orient)
--    local v_perp, v_parr = Rotate(ball.xdot,ball.ydot,wall_orient)
--    ball.xdot, ball.ydot = Rotate(-v_perp,v_parr,-wall_orient)
-- end




function Rotate(x,y,angle)
   newx = x*math.cos(angle) - y*math.sin(angle)
   newy = x*math.sin(angle) + y*math.cos(angle)
   return newx ,newy
end

-- Predicts the position of the ball when it reaches ownx
function Predict(stick,ball,side)
   local t = -1*side*math.abs(stick.x+side*stick.w-ball.x)/ball.xdot
   local y = ball.y + ball.ydot*t
   local h = love.window.getHeight() - ball.h
   local trav = math.floor(y/h)
   return (trav%2)*h+(-1)^trav*(y%h)
end
