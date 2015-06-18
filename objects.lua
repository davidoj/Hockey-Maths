
object = {}

object_mt = {__index = object}

ball = {
   x = 10,
   y = 10,
   w = 30,
   h = 30,
   theta = 0,
   xdot = 300,
   ydot = 300,
   thetadot = 0,
   img = love.graphics.newImage('svg/redBall.png')
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
   img = love.graphics.newImage('svg/hockeyStick.png')
}

function object:update_vertices()

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

function stick:create(x,y)
   local st = {}
   for i, v in pairs(self) do
      st[i] = v
   end
   st.x = x
   st.y = y
   st = object:create(st)
   st:update_vertices()
   return st
end

function ball:create()
   local b = object:create(ball)
   b:update_vertices()
   return b
end

function object:update(dt)
   local xdot = self.xdot*dt or 0
   local ydot = self.ydot*dt or 0
   local thetadot = self.thetadot*dt or 0
   self.x = self.x + xdot
   self.y = self.y + ydot
   self.theta = self.theta + thetadot
   self:update_vertices()
end

function draw_object(obj)
   local theta = obj.theta or 0
   love.graphics.draw(obj.img,obj.x,obj.y,theta,1,1,obj.ox,obj.oy)
end

function setup_objects_and_borders()
   borders = {
      xMin = 0,
      xMax = love.window.getWidth(),
      yMin = 0,
      yMax = love.window.getHeight()
   }

   l_stick = stick:create(50,200)
   r_stick = stick:create(750,200)
   ball = ball:create()

end