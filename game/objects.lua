-- methods for creating and updating objects in game

require "util/util"

object = {}

object_mt = {__index = object}

function object:create()
   obj =  {actions = {},
           observers = {},
           counter = 0
          }
   setmetatable(obj,object_mt)
   return obj
end

function object:update(dt)

   self:execute(self.actions[1],dt)

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

function object:getNextAction()
   table.remove(self.actions,1)
end
