-- methods for creating and updating objects in game


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

local rigid_body = object:create()

rigid_body.x = 0
rigid_body.y = 0
rigid_body.w = 0
rigid_body.h = 0
rigid_body.ox = 0
rigid_body.oy = 0
rigid_body.theta = 0
rigid_body.xdot = 0
rigid_body.ydot = 0
rigid_body.thetadot = 0
rigid_body.thetadotmax = 1.5
rigid_body.xaccel = 0
rigid_body.yaccel = 0
rigid_body.thetaaccel = 0

local rigid_body_mt = {__index = rigid_body }

function rigid_body:create()
   local rb = {}
   for i, v in pairs(rigid_body) do
      rb.i = v
   end
   setmetatable(rb,rigid_body_mt)
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


local stick = {}

function stick:create(x,y,side)
   local st = rigid_body:create()

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

local ball = {}

function ball:create()
   local b = rigid_body:create()

   b.x = 10
   b.y = 10
   b.w = 30
   b.h = 30
   b.xdot = 300
   b.ydot = 300
   b.img = love.graphics.newImage('art/redBall.png')

   b:updateVertices()
   b.actions = {}
   return b
end

function object:update(dt)
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


function rigid_body:update(dt)
   local xdot = self.xdot*dt or 0
   local ydot = self.ydot*dt or 0
   local thetadot = self.thetadot*dt or 0
   self.x = self.x + xdot
   self.y = self.y + ydot
   self.theta = self.theta + thetadot

   self.xdot = self.xdot + self.xaccel*dt
   self.ydot = self.ydot + self.yaccel*dt
   self.thetadot = self.thetadot + self.thetaaccel*dt
   self:updateVertices()
end

function ball:update(dt)
   
   self:HandleObjectCollision(l_stick,dt)
   self:HandleObjectCollision(r_stick,dt)
   self:HandleWallCollision(borders)
   
   rigid_body.update(self,dt)
end

function stick:update(dt,ball_bounced)
      

   if self.side == 1 then
      while self.theta > 3*math.pi/2 do self.theta = self.theta - 2*math.pi end
   end
   if self.side == -1 then
      while self.theta < math.pi/2 do self.theta = self.theta + 2*math.pi end
   end
   rigid_body.update(self,dt) 
  
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

-- a special update call for sticks and questions when the ball collides with a stick or either side of the screen
