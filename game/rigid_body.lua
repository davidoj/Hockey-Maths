require "game/objects"
require "util/util"

rigid_body = {}
rigid_body_mt = {__index = rigid_body }
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
   rb.thetadotmax = 5
   rb.dampthreshold = 1.5
   rb.xaccel = 0
   rb.yaccel = 0
   rb.thetaaccel = 0


   return rb
end

function rigid_body:update(dt)
   object.update(self,dt)
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

function rigid_body:display()
   love.graphics.draw(self.img,self.x,self.y,self.theta,1,1,self.ox,self.oy)
end

function rigid_body:updateVertices()

   local ox, oy = self.ox or 0, self.oy or 0
   local x1 = -ox + self.x
   local x2 = x1 + self.w
   local y1 = -oy + self.y
   local y2 = y1 + self.h
   
   self.vertices = {x1,y1,x2,y1,x2,y2,x1,y2}
end

function rigid_body:Rotate(x,y,angle)
   newx = x*math.cos(angle) - y*math.sin(angle)
   newy = x*math.sin(angle) + y*math.cos(angle)
   return newx ,newy
end
