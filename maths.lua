-- Updated maths question generator
-- The idea is to store a library of "already seen" questions with accuracy and (eventually) response time data
-- then generating new questions by selecting from & manipulating these ones
-- David Johnston 2015

--[[ 
   Todo: I want to make equations go 'term' '=' 'term' 
   where a term is either 'number' or 'term' 'op' 'term'
   
   But for the moment I just have questions that go 'number' 'op' 'number' '=' 'number'
]]--

local opPlus = {
   func = function(x,y) return x+y end,
   sym = '+'
}

local opMinus = {
   func = function(x,y) return x-y end,
   sym = '-'
}

local opTimes = {
   func = function(x,y) return x*y end,
   sym = string.char(0xc3,0x97)
}

local opDiv = {
   func = function(x,y) return x/y end,
   sym = string.char(0xc3,0xb7)
}

local question = {
   free = 1,
   trial_answer = nil,
   terms = {'1','1','2'},
   op = opPlus,
   accuracy = 0,
   response_time = 10,
   attempts = {}
}

local question_mt = { __index = question }

question_db = {question}

local function opComplement(op)
   if op.sym == opPlus.sym then return opMinus
   elseif op.sym == opMinus.sym then return opPlus
   elseif op.sym == opTimes.sym then return opDiv
   elseif op.sym == opDiv.sym then return opTimes
   end
   error("operation doesn't match anything")
end

local function isCommutative(op)
   return (op.sym == '+' or op.sym == '*')
end

function question:commute()
   -- assert(isCommutative(self.op), 'attempting to commute noncommutative operation')
   local newq = deepcopy(self)
   if isCommutative(self.op) then
      newq.terms[2] = self.terms[1]
      newq.terms[1] = self.terms[2]
   else
      newq.terms[2] = self.terms[3]
      newq.terms[3] = self.terms[2]
   end
   return newq
end

function question:complement()
   local newq = deepcopy(self)
   newq.terms[1] = self.terms[3]
   newq.terms[3] = self.terms[1]
   newq.op = opComplement(self.op)
   return newq
end

function question:incrementTerm(pos)
   local newq = deepcopy(self)
   local p = pos or 1
   newq.terms[p] = newq.terms[p] + 1
   return newq
end
   
function question:movePrompt()
   local newq = deepcopy(self)
   newq.free = (self.free+1)%3 + 1
   return newq
end

local modifiers = {question.commute,question.complement,question.incrementTerm,question.movePrompt}

local weights = {0.5,0.5,0.5,0.5}

function question:create()
   q = {}
   setmetatable(q,question_mt)
   return q
end


function question:isEqual(q)
   return (self.terms[1] == q.terms[1] 
              and self.terms[2] == q.terms[2] 
              and self.terms[3] == q.terms[3] 
              and self.op.sym == q.op.sym)
end


function question:toString()
   local terms = deepcopy(self.terms)
   terms[self.free] = '_'
   local str = terms[1] .. self.op.sym .. terms[2] .. '=' .. terms[3]
   return str
end

function question:checkAnswer()
   local terms = deepcopy(self.terms)
   terms[self.free] = self.trial_answer
   local test = tostring(self.op.func(terms[1],terms[2]))
   if test == tostring(terms[3]) then
      tr = love.timer.getTime() - timer
      self.response_time = self.response_time + alpha*(tr - self.response_time)
      self.accuracy = self.accuracy + alpha*(1-self.accuracy)
      return 1
   else
      self.accuracy = self.accuracy + alpha*(-self.accuracy)
      return 0
   end
end

function question:computeWeight()
   local last_try = self.attempts[#self.attempts]
   local c1, c2, c3 = 1,1,1
   local f1 = math.min(1/4, math.exp(c3*self.response_time/(1.01 - self.accuracy)))
   return math.min(f1, (total_attempts - last_try)*f1)
end

function question_db:isValid(question)
   for _, q in ipairs(self) do
      if question.isEqual(question,q) then
         return false
      end
   end
   for _, t in ipairs(question.terms) do
      if tonumber(t) < 0 then
         return false
      end
   end
   return true 
end


function question_db:queryTerms(positions,min_success)
   local min_success = min_success or 0
   local position =  positions or {1,2,3}
   local terms = {}
   for _, v in pairs(question_db) do
      if v.correct/v.attempts > min_success then
         for _, p in ipairs(position) do
            table.insert(terms,v.terms[j])
         end
      end
   end  
   return terms
end

function question_db:getNewQuestion()
   local prototype = self[math.random(#self)]
   local valid = false
   while not valid do
      for i, fun in ipairs(modifiers) do
         if math.random() > weights[i] then
            prototype = fun(prototype)
         end
      end
      valid = self:isValid(prototype)
   end
   table.insert(self,prototype)
   return prototype
end

function question_db:getRandomQuestion()
   return self[math.random(#self)]
end

function question_db:selectRandomByWeight()
   local cum = 0
   local trial = math.random()
   local quest = nil
   for _, q in self do
      cum = cum + q:computeWeight()
      if cum > trial then 
         quest = q
         break 
      end
   end
   if not quest then
      quest = self:getNewQuestion()
   end
   return quest
end
