
require "game/objects"
require "game/rigid_body"

ball = {}
ball_mt = { __index = ball }
setmetatable(ball,rigid_body_mt)

function ball:create()
   local b = rigid_body:create()
   setmetatable(b,ball_mt)
   b.x = 10
   b.y = 10
   b.w = 30
   b.h = 30
   b.xdot = 300
   b.ydot = 300
   b.img = love.graphics.newImage('art/redBall.png')

   b:updateVertices()

   return b
end

function ball:update(dt)
   self:handleObjectCollision(l_stick,dt)
   self:handleObjectCollision(r_stick,dt)
   self:handleWallCollision(borders)

   rigid_body.update(self,dt)
end

function ball:accelerate(mult)
   mult = mult or 5
   return function(dt)
      self:sendNote({event = 'speed_change'})
      self.xdot = self.xdot*mult
      self.ydot = self.ydot*mult
      self:getNextAction()
   end
end

function ball:setSpeed(speed)
   speed = speed or 425
   return function(dt)
      self:sendNote({event = 'speed_change'})
      local v = math.sqrt(self.xdot^2 + self.ydot^2)
      self.xdot = speed*self.xdot/v
      self.ydot = speed*self.ydot/v
      self:getNextAction()
   end
end

function ball:resetAndWait(t)
   self:sendNote({event = 'ball_reset'})
   t = t or math.huge
   return function (dt)
      self.x = borders.xMax/2
      self.y = borders.yMax/2
      if self.counter > t then
         self:sendNote({event = 'ball_restart'})
         self:getNextAction()
         self.counter = 0
      end
      self.counter = self.counter + dt
   end
end


function ball:reflect(ccode,with)
   return function(dt)
      self:sendNote({event = 'collision', with = with, ccode = ccode})
      if with == 'wall' and ccode[1] ~= 0 then
         self:sendNote({event = 'goal', side = -ccode[1]})
      end
      if ccode[1]~=0 then
         self.xdot = math.abs(self.xdot)*ccode[1]
      end
      if ccode[2]~=0 then
         self.ydot = math.abs(self.ydot)*ccode[2]+100*(math.random()-0.5)
      end
      self:getNextAction()
   end
end


function ball:handleNote(from,note)
   if note['event'] == 'collision' and
      note['ccode'][1] == 1
   then
      table.insert(self.actions,self:setSpeed())
   end

   if note['event'] == 'correct_answer' then
      table.insert(self.actions,self:accelerate())
   end

   if note['event'] == 'update_score' and note['side'] == -1 then
      table.insert(self.actions,self:resetAndWait(3))
   end
end

-- collision detection



local function cId2ccode(cId)
   local c = {0,0}
   if cId == 1 then c = {-1,0}
   elseif cId == 2 then c = {0,-1}
   elseif cId == 3 then c = {1,0}
   elseif cId == 4 then c =  {0,1}
   end
   return c
end

local function WallCollision(obj,borders)
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


local function objectCollision(objR,objS)
   if objS.active == 0 then
      return -1, 0
   end

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
            cId = i
         end
      end
   else return -1, 0
   end

   return maxMin, cId
end


function ball:handleObjectCollision(obj,dt)
   local tc, sc = objectCollision(self,obj)
   sc = cId2ccode(sc)

   if tc<dt and tc>=0 and sc and #self.actions == 0 then
       table.insert(self.actions,self:reflect(sc,'stick'))
   end
end

function ball:handleWallCollision(borders)
   local wc = WallCollision(self,borders)
   if (wc[1] ~= 0  or wc[2] ~= 0) and #self.actions == 0 then
      table.insert(self.actions,self:reflect(wc,'wall'))
   end
end
