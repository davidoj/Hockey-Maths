-- behaviours that objects can execute

require "objects"
require "util"

function time_to_hit(stick,ball)
   local t = -1*stick.side*math.abs(sx+stick.side*stick.w-ball.x)/ball.xdot
   return t
end
-- Predicts the y position of the ball when it reaches object's x position
function predict(stick,ball)
   sx = stick.x - stick.ox
   local t = time_to_hit(stick,ball)
   local y = ball.y + ball.ydot*t
   local h = love.window.getHeight() - ball.h
   local trav = math.floor(y/h)
   return (trav%2)*h+(-1)^trav*(y%h), t
end

-- accelerate stick to specified pos, angle at time delta_t 
function stick:accel_to_point(x,y,angle,delta_t)
   a = {angle,2*math.pi+angle}
   angle = a[math.random(2)]

   local d_theta = angle - self.theta
   local d_x, d_y = x - self.x, y - self.y

   self.xaccel = 2*(d_x - self.xdot*delta_t)/delta_t^2
   self.yaccel = 2*(d_y - self.ydot*delta_t)/delta_t^2
   self.thetaaccel = 2*(d_theta - self.thetadot*delta_t)/delta_t^2

end

-- move stick smoothly to intercept ball
function stick:seek_ball(dt)
   local py, delta_t = predict(self,ball)
   
   if self.e_time == 0 then 
      self:accel_to_point(self.x,py+self.oy,0,delta_t)
   end
   
   self.e_time = self.e_time + dt

   return delta_t
end


-- Idle animation for the stick
function stick:idle(dt)

   local tdot = self.thetadot
   if tdot < self.thetadotmax then
      tdot = 0
   end

   local theta = self.theta

   self.thetaaccel =  (self.side*3/2 - theta - 0.15*tdot)/0.01

   self.yaccel = (200 - self.y + self.oy - 0.15*self.ydot)/0.01

   self.e_time = self.e_time + dt

   return 0

end

-- wait until the ball is close to the stick
function stick:wait_for_ball(dt)
   
   local dx = self.side*(ball.x-self.x)
   local xdot = ball.xdot*self.side

   if (dx*xdot > 0 or dx <= 0) then -- wait for collision, then check again
      table.insert(self.actions,1,self.idle)
      return math.huge
   end

   local dwait = math.max(0,math.abs(dx-250))

   local delta_t = math.abs(dwait/ball.xdot)

   self.e_time = self.e_time + dt
   self:idle(dt)

   return delta_t
end
