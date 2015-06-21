-- methods for creating and updating objects in game


object = {}

object_mt = {__index = object}

ball = {
   x = 10,
   y = 10,
   w = 30,
   h = 30,
   ox = 0,
   oy = 0,
   theta = 0,
   xdot = 300,
   ydot = 300,
   thetadot = 0,
   xaccel = 0,
   yaccel = 0,
   thetaaccel = 0,
   img = love.graphics.newImage('art/redBall.png')
}

stick = {
   w = 30,
   h = 130,
   ox = 15,
   oy = 130,
   theta = 0,
   xdot = 0,
   ydot = 0,
   thetadot = 0,
   thetadotmax = 1.5,
   xaccel = 0,
   yaccel = 0,
   thetaaccel = 0,
   wait = 0,
   e_time = 0, -- timer for action execution
   img = love.graphics.newImage('art/hockeyStick.png')
}

function object:updateVertices()

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

function object:create(obj)
   obj = obj or {}
   setmetatable(obj,object_mt)
   return obj
end

function stick:create(x,y,side)
   local st = {}
   for i, v in pairs(self) do
      st[i] = v
   end
   st.x = x
   st.y = y
   st.side = side
   st.actions = {}
   st = object:create(st)
   st:updateVertices()
   return st
end

function ball:create()
   local b = object:create(ball)
   b:updateVertices()
   return b
end

function object:update(dt)
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
   
   object.update(self,dt)
end

function stick:update(dt,ball_bounced)
      
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

   if self.side == 1 then
      while self.theta > 3*math.pi/2 do self.theta = self.theta - 2*math.pi end
   end
   if self.side == -1 then
      while self.theta < math.pi/2 do self.theta = self.theta + 2*math.pi end
   end
   object.update(self,dt) 
  
end

function stick:execute(action,dt)
   local t = 0
   if action ~= nil then
      t = action(self,dt)       
   else 
      self:idle(dt)      
   end
   return t
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

end

-- a special update call for sticks and questions when the ball collides with a stick or either side of the screen
function onBallCollision(ccode) 
   l_stick:update(0,1)
   r_stick:update(0,1)
   
   if ccode[1] == 1 then 
      table.insert(r_stick.actions,r_stick.waitForBall)
      table.insert(r_stick.actions,r_stick.seekBall)
   end
   
end
