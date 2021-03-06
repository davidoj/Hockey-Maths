
require "game/objects"

questioner = object:create()
questioner_mt = {__index = questioner}

function questioner:init(qdb)

   local q = {
      trial_answer = '',
      question = qdb:getRandomQuestion(),
      wait_for_input = true,
      db = qdb,
      total_attempts = 0,
      timer = love.timer.getTime()
   }

   setmetatable(q,questioner_mt)
   return q
end

function questioner:display()

   local terms = deepcopy(self.question.terms)
   local str
   local trial_answer = self.trial_answer
   if self.wait_for_input then
      terms[self.question.free] = '_'
      trial_answer = trial_answer .. '_'
      str = terms[1] .. self.question.op.sym .. terms[2] .. '=' .. terms[3]
      love.graphics.print(str,350,200)
   else 
      str = terms[1] .. self.question.op.sym .. terms[2] .. '=' .. terms[3]
      love.graphics.setColor(0, 255, 0, 255)
      love.graphics.print(str,350,200)
      love.graphics.setColor(255, 255,255, 255)
   end
      
   love.graphics.print(trial_answer,350,250)

end


function questioner:handleInput(key)
   if self.wait_for_input then
      for _,value in ipairs({'1','2','3','4','5','6','7','8','9','0','-'}) do
         if value == key then
            self.trial_answer = self.trial_answer .. key 
         end
      end

      if key == 'backspace' and #self.trial_answer>0 then
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
      note['ccode'][1] == 1
   then
      self:getNextAction()
   end

   if note['event'] == 'correct_answer' then
      table.insert(self.actions,self:pauseOnCorrect())
      table.insert(self.actions,self:getNewQuestion())
   end

   if note['event'] == 'ball_reset' then
      table.insert(self.actions,self:pauseOnCorrect())
   end

   if note['event'] == 'ball_restart' then
      self:getNextAction()
   end
end

function questioner:checkAnswer()
   local terms = deepcopy(self.question.terms)
   terms[self.question.free] = self.trial_answer
   local test = tostring(self.question.op.func(terms[1],terms[2]))
   print('Prev: accuracy = ' .. self.question.accuracy .. ' rt = ' .. self.question.response_time .. '\n')
   if test == tostring(terms[3]) then
      tr = love.timer.getTime() - self.timer
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
      self:getNextAction()
      self:sendNote({event = 'new_question'})
   end
end

function questioner:idle()
   return function (dt) 
      self.wait_for_input = true
   end
end

function questioner:pauseOnCorrect(t)
   print('correct!')
   t = t or math.huge
   return function (dt) 
      self.wait_for_input = nil
      if self.counter > t then
         self.getNextAction()
         self.counter = 0
      end
      self.counter = self.counter + dt
   end
end
