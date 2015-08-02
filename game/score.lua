
require "game/objects"

score = object:create()
score_mt = {__index = score}

function score:init(side)
   local s = {
      goals = 0,
      side = side,
      frozen = false
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
   if note['event'] == 'goal' and note['side'] == self.side and not self.frozen then
      self.goals = self.goals+1
      self.frozen = false
   end
   if note['event'] == 'correct_answer' and self.side == -1 then
      self.frozen = true -- no unfair goals against player
   end
end
