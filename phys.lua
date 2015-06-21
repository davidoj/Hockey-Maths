-- Collision detection

require "math"
require "objects"
-- Checks for collision between reactive and 'static' object, returns index of face of static object
-- first collided with (1-4 starting from left)
-- Or a negative collision time if no collision

function ObjectCollision(objR,objS)
   --local minT = math.huge
   sx, sy = objS.x - objS.ox, objS.y - objS.oy
   rx, ry = objR.x - objR.ox, objR.y - objR.oy
   local ux, uy = objS.xdot-objR.xdot, objS.ydot-objR.ydot
   local dx1, dx2 = sx-rx-objR.w, sx+objS.w-rx
   local dy1, dy2 = sy-ry-objR.h, sy+objS.h-ry
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
   x, y = obj.x - obj.ox, obj.y - obj.oy
   if x < borders.xMin then c[1] = 1
   elseif x+obj.w >= borders.xMax then c[1] = -1
   end
   if y < borders.yMin then c[2] = 1
   elseif y + obj.h >= borders.yMax then c[2] = -1
   end
   return c
end

-- Reflects object from vertical or horizontal surface

function object:ReflectFromSurface(ccode)
   if ccode[1]~=0 then
      self.xdot = math.abs(self.xdot)*ccode[1]
   end
   if ccode[2]~=0 then
      self.ydot = math.abs(self.ydot)*ccode[2]
   end
end

function ball:HandleObjectCollision(obj,dt)
   local tc, sc = ObjectCollision(self,obj)

   if tc<dt and tc>=0 and sc then
       self:ReflectFromSurface(cId2ccode(sc))
       onBallCollision()
   end
end

function object:HandleWallCollision(borders)
   local wc = WallCollision(self,borders)
   if wc then 
      self:ReflectFromSurface(wc) 
      if wc[1] ~= 0 then
         onBallCollision()
      end
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
