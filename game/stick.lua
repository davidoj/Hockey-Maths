
require "game/objects"
require "game/rigid_body"

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


function stick:update(dt) 

   if self.side == 1 then
      while self.theta > 3*math.pi/2 do self.theta = self.theta - 2*math.pi end
      while self.theta < -math.pi/2 do self.theta = self.theta + 2*math.pi end
   end
   if self.side == -1 then
      while self.theta < math.pi/2 do self.theta = self.theta + 2*math.pi end
      while self.theta > 7*math.pi/2 do self.theta = self.theta - 2*math.pi end
   end
   rigid_body.update(self,dt)
  
end



function stick:handleNote(from, note)

   if note['event'] == 'collision' and
      note['ccode'][1] == -self.side
   then
      if self.side == -1 then
         self.actions = {}
         self.recalculate=true
         table.insert(self.actions,self:waitForBall())
         table.insert(self.actions,self:seekBall())
      end
      --self:update(0)
   end
   
   if note['event'] == 'correct_answer' then
      if self.side == 1 then
         self.actions = {}
         self.recalculate = true
         table.insert(self.actions,self:waitForBall())
         table.insert(self.actions,self:seekBall())
      end
   end


   if note['event'] == 'speed_change' then
      self.recalculate = true
   end
end


-- Some animations


local function time_to_hit(stick,ball)
   local t = -1*stick.side*math.abs(sx+stick.side*stick.w-ball.x)/ball.xdot
   return t
end

local function predict(stick,ball)
   sx = stick.x - stick.ox
   local t = time_to_hit(stick,ball)
   local y = ball.y + ball.ydot*t
   local h = love.window.getHeight() - ball.h
   local trav = math.floor(y/h)
   return (trav%2)*h+(-1)^trav*(y%h), t
end


function stick:idle()
   
   return function (dt)
      local tdot = self.thetadot
      if math.abs(tdot) < self.dampthreshold then
         tdot = 0
      end

      self.thetaaccel =  ((2-self.side)*math.pi/2 - self.theta - 0.15*tdot)/0.01

      self.yaccel = (200 - self.y + self.oy - 0.15*self.ydot)/0.01

   end

end


function stick:seekBall()
   return function (dt)
      local py, delta_t = predict(self,ball)
      
      a =  {0,2*math.pi}
      angle = a[math.random(2)]

      if  self.recalculate then
         self.recalculate = nil
         self:accelToPoint(self.x,py+self.oy,angle,delta_t)
      end

      if delta_t <= 0.01 then
         self:getNextAction()
      end
   end
end


function stick:waitForBall()
   return function (dt)
      local dx = self.side*(ball.x-self.x)
      local xdot = ball.xdot*self.side

      if (dx*xdot > 0 or dx < 0) then -- wait for collision, then check again
         table.insert(self.actions,1,self:idle(dt))
         return math.huge
      end
      if dx-400 > 0 then
         self:idle()(dt)
      else
         self:getNextAction()
      end
   end
end

function stick:accelToPoint(x,y,angle,delta_t)

   local d_theta = angle - self.theta
   local d_x, d_y = x - self.x, y - self.y

   self.xaccel = 2*(d_x - self.xdot*delta_t)/delta_t^2
   self.yaccel = 2*(d_y - self.ydot*delta_t)/delta_t^2
   self.thetaaccel = 2*(d_theta - self.thetadot*delta_t)/delta_t^2

end
