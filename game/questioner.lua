
require "game/objects"

questioner = object:create()
questioner_mt = {__index = questioner}

function questioner:init(qdb)

   local q = {
      trial_answer = '',
      question = qdb:getRandomQuestion(),
      wait_for_input = true,
   }

   setmetatable(q,questioner_mt)
   return q
end

function questioner:display()

   local terms = deepcopy(self.question.terms)
   if self.wait_for_input then
      love.graphics.setColor(255,255,255,255)
      terms[self.question.free] = '_'
   else 
      love.graphics.setColor(0, 255, 0, 255)
   end
      
   local str = terms[1] .. self.question.op.sym .. terms[2] .. '=' .. terms[3]


   love.graphics.print(str,350,200)
   love.graphics.print(self.trial_answer,350,250)

end


function questioner:checkAnswer()
   table.insert(self.question.attempts,total_attempts)
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

function questioner:computeWeight()
   local last_try = self.question.attempts[#self.question.attempts]
   local c1 = 14
   local tr = math.max(self.question.response_time,0.51)
   --local f1 = math.min(1/4, math.exp(-c3/(self.question.response_time*(1.01 - self.question.accuracy))))
   local f1 = math.min(1/4, math.exp(-c1/(tr-0.5)))
   return math.min(f1, 0.1*(total_attempts - last_try)*f1)
end

function questioner:getNewQuestion(qdb)
   return function (q,dt)
      self.question = qdb:getNewQuestion()
      table.remove(self.actions,1)
      return 0
   end
end

function questioner:beginWaiting(t)
   t = t or math.huge
   return function (q,dt) 
      self.wait_for_input = true
      return t 
   end
end

function questioner:pause_on_correct(t)
   t = t or math.huge
   return function (q,dt) self.wait_for_input = nil return t end
end

function questioner:idle(dt)
   return self:beginWaiting()()
end
