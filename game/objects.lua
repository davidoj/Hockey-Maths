-- methods for creating and updating objects in game

require "util/util"

object = {}

object_mt = {__index = object}

function object:create()
   obj =  {actions = {},
           wait = 0,
           e_time = 0,
           observers = {}
          }
   setmetatable(obj,object_mt)
   return obj
end

function object:update(dt,force_update)
   if (self.e_time >= self.wait)or
      force_update
   then
      if self.wait > 0 or force_update then 
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
      t = action(dt)       
   else
      self:idle()(dt)      
   end
   return t

end

function object:sendNote(note)
   for _, o in pairs(self.observers) do
      o:handleNote(self,note)
   end
end

function object:addObserver(obs)
   table.insert(self.observers,obs)
end

function object:idle(dt)
   return function () return 0 end
end

function draw_object(obj)
   local theta = obj.theta or 0
   love.graphics.draw(obj.img,obj.x,obj.y,theta,1,1,obj.ox,obj.oy)
end
