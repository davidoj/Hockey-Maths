-- Maths question generator
-- David Johnston 2015


Question = {
   free = 0,
   args = {'_','_','_'},
   op = '_',
   correct = 0
}

Question_mt = { __index = Question }

Params = {
   range = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
   ops = {'+','-'} -- 'x'}--,'/'}
}

function Question:execute()
   local x, y = self.args[1],self.args[2]
   if self.op == '+' then return x+y 
   elseif self.op == '-' then return x-y
   elseif self.op == 'x' then return x*y
   elseif self.op == '/' then return x/y
   end
end


function createRandomQuestion(ops)
   local question = {}
   local free = math.random(3)
   setmetatable(question,Question_mt)
   question.free = free
   question.args = {'_','_','_'}
   for i, v in ipairs(question.args) do
      if i ~= free then
         question.args[i] = tostring(math.random(10))
      end
   end
   
   local choice = math.random(#ops)
   question.op = ops[choice]

   question.correct = 0

   return question
end

function Question:toString()
   local str = self.args[1] .. self.op .. self.args[2] .. '=' .. self.args[3]
   return str
end

function Question:checkAnswer(answer)
   self.args[self.free] = answer
   local test  = tostring(self:execute())
   if test == self.args[3] then
     
      self.correct = 1
      return 1
   else
      return 0
   end
end
