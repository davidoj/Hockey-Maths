
require "game/objects"

questioner = object:create()
questioner_mt = {__index = questioner}

function questioner:init(qdb)

   local q = {
      trial_answer = '',
      question = qdb:getRandomQuestion(),
      wait_for_input = true,
      db = qdb,
      total_attempts = 0
   }

   setmetatable(q,questioner_mt)
   return q
end

function questioner:display()

   local terms = deepcopy(self.question.terms)
   local str
   if self.wait_for_input then
      terms[self.question.free] = '_'
      str = terms[1] .. self.question.op.sym .. terms[2] .. '=' .. terms[3]
      love.graphics.print(str,350,200)
   else 
      str = terms[1] .. self.question.op.sym .. terms[2] .. '=' .. terms[3]
      love.graphics.setColor(0, 255, 0, 255)
      love.graphics.print(str,350,200)
      love.graphics.setColor(255, 255,255, 255)
   end
      
   love.graphics.print(self.trial_answer,350,250)

end


function questioner:handleInput(key)
   if self.wait_for_input then
      for _,value in ipairs({'1','2','3','4','5','6','7','8','9','0','-'}) do
         if value == key then
            self.trial_answer = self.trial_answer .. key
         end
      end

      if key == 'backspace' and #ans>0 then
         self.trial_answer = string.sub(self.trial_answer,1,-2)
      end
      
      if key == 'return' and self.trial_answer ~= '' then
         local r = self:checkAnswer()
         self.trial_answer = ''
         table.insert(self.question.attempts,self.total_attempts)
         self.total_attempts = self.total_attempts + 1
         if r==1 then
            self:sendNote({event = 'correct_answer'})
         end
      end
   end
end



function questioner:handleNote(from, note)
   if note['event'] == 'collision' and
      note['ccode'][1] == -1
   then
      self:update(0,1)
   end

   if note['event'] == 'correct_answer' then
      table.insert(self.actions,self:pauseOnCorrect())
      table.insert(self.actions,self:getNewQuestion())
   end
end

function questioner:checkAnswer()
   local terms = deepcopy(self.question.terms)
   terms[self.question.free] = self.trial_answer
   local test = tostring(self.question.op.func(terms[1],terms[2]))
   print('Prev: accuracy = ' .. self.question.accuracy .. ' rt = ' .. self.question.response_time .. '\n')
   if test == tostring(terms[3]) then
      tr = love.timer.getTime() - timer
      self.question.response_time = math.min(10,self.question.response_time + alpha*(tr - self.question.response_time))
      self.question.accuracy = self.question.accuracy + alpha*(1-self.question.accuracy)
      print('New: accuracy = ' .. self.question.accuracy .. ' rt = ' .. self.question.response_time .. '\n')
      return 1
   else
      self.question.accuracy = self.question.accuracy + alpha*(-self.question.accuracy)
      print('New: accuracy = ' .. self.question.accuracy .. ' rt = ' .. self.question.response_time .. '\n')
      return 0
   end
end

function questioner:getNewQuestion()
   return function (dt)
      self.question = self.db:selectRandomByWeight(self.total_attempts)
      table.remove(self.actions,1)
      return 0
   end
end

function questioner:idle()
   local t = math.huge
   return function (dt) 
      self.wait_for_input = true
      return t 
   end
end

function questioner:pauseOnCorrect()
   print('correct!')
   local t =  math.huge
   return function (dt) self.wait_for_input = nil return t end
end
