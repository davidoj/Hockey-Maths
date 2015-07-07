-- methods for creating and updating objects in game

require "util/util"

object = {}

object_mt = {__index = object}

function object:create()
   obj =  {actions = {},
           wait = 0,
           e_time = 0,
          }
   setmetatable(obj,object_mt)
   return obj
end

rigid_body = {}
local rigid_body_mt = {__index = rigid_body }
setmetatable(rigid_body,object_mt)

function rigid_body:create()
   local rb = object:create()

   rb.x = 0
   rb.y = 0
   rb.w = 0
   rb.h = 0
   rb.ox = 0
   rb.oy = 0
   rb.theta = 0
   rb.xdot = 0
   rb.ydot = 0
   rb.thetadot = 0
   rb.thetadotmax = 1.5
   rb.xaccel = 0
   rb.yaccel = 0
   rb.thetaaccel = 0


   return rb
end

function rigid_body:updateVertices()

   -- local s, c = math.sin(self.theta), math.cos(self.theta) 
   -- local x1 = -ox + self.x + (1-c)*self.w/2
   -- local x2 = -ox + self.x + self.h*s + (1-s)*self.w
   
   -- local y1 = -oy + self.y + self.h*(1-c) + s*self.w/2
   -- local y2 = -oy + self.y + self.h + s*self.w/2

   local ox, oy = self.ox or 0, self.oy or 0
   local x1 = -ox + self.x
   local x2 = x1 + self.w
   local y1 = -oy + self.y
   local y2 = y1 + self.h
   
   self.vertices = {x1,y1,x2,y1,x2,y2,x1,y2}
end


stick = {}
stick_mt = {__index = stick}
setmetatable(stick,rigid_body_mt)

function stick:create(x,y,side)
   local st = rigid_body:create()

   setmetatable(st,stick_mt)

   st.w = 30
   st.h = 130
   st.ox = 15
   st.oy = 130
   st.img = love.graphics.newImage('art/hockeyStick.png')
   
   st.x = x
   st.y = y
   st.side = side

   st:updateVertices()

   return st
end

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

function draw_object(obj)
   local theta = obj.theta or 0
   love.graphics.draw(obj.img,obj.x,obj.y,theta,1,1,obj.ox,obj.oy)
end

function setupObjectsAndBorders()
   borders = {
      xMin = 0,
      xMax = love.window.getWidth(),
      yMin = 0,
      yMax = love.window.getHeight()
   }

   l_stick = stick:create(50,200,1)
   r_stick = stick:create(750,200,-1)
   ball = ball:create()

   table.insert(r_stick.actions,r_stick.waitForBall)
   table.insert(r_stick.actions,r_stick.seekBall)


end


function object:idle(dt)
   return 0
end


function object:update(dt,ball_bounced)
   if (self.e_time >= self.wait) or
      (ball_bounced and self.wait == math.huge)
   then
      if self.wait > 0 then -- get new action
         table.remove(self.actions,1)  
      end
      self.e_time = 0
      self.wait = self:execute(self.actions[1],dt)
   else 
      self:execute(self.actions[1],dt)
   end   
end


function object:execute(action,dt)
   local t = 0
   if action ~= nil then
      t = action(self,dt)       
   else
      self:idle(dt)      
   end
   return t

end
