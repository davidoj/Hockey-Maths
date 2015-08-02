
require "game/objects"

score = object:create()
score_mt = {__index = score}

function score:init(side)
   local s = {
      goals = 0,
      side = side
   }

   setmetatable(s,score_mt)
   return s
end

function score:display()
   if self.side == -1 then
      love.graphics.setColor(220,20,60) -- crimson
   elseif self.side == 1 then
      love.graphics.setColor(30,144,255) -- 'dodger blue'
   end
   love.graphics.print(self.goals,400-350*self.side,50)
   love.graphics.setColor(255,255,255)
end

function score:handleNote(from, note)
   if note['event'] == 'goal' and node[side] == self.side then
      self.goals = self.goals+1
   end
end
