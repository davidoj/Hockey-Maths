-- The idea is to store a library of "already seen" questions with accuracy and (eventually) response time data
-- then generating new questions by selecting from & manipulating these ones
-- David Johnston 2015

require "objects"

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


local parameters = {
   terms = {'1','1','2'},
   op = opPlus,
   accuracy = 0,
   response_time = 10,
   attempts = {}
}

local parameters_mt = { __index = parameters }

local question = object:create()

question.free = 1
question.trial_answer = ''
question.params = parameters
question.wait_for_input = nil

local question_mt = { __index = question }

local param_db = {}
local param_db_mt = { __index = param_db }

function initialiseParamDB()
   local pdb
   if love.filesystem.exists('pdb.lua') then
      save_pdb = love.filesystem.load('pdb.lua')
      pdb = save_pdb()
   else
   pdb = {question}
   end
   setmetatable(pdb,param_db_mt)
   return pdb
end


local function opComplement(op)
   if op.sym == opPlus.sym then return opMinus
   elseif op.sym == opMinus.sym then return opPlus
   elseif op.sym == opTimes.sym then return opDiv
   elseif op.sym == opDiv.sym then return opTimes
   end
   error("unhandled operation")
end

local function isCommutative(op)
   return (op.sym == '+' or op.sym == string.char(0xc3,0x97))
end

function question:display()

   local terms = deepcopy(self.params.terms)
   if self.wait_for_input then
      love.graphics.setColor(255,255,255,255)
      terms[self.free] = '_'
   else 
      love.graphics.setColor(0, 255, 0, 255)
   end
      
   local str = terms[1] .. self.params.op.sym .. terms[2] .. '=' .. terms[3]


   love.graphics.print(str,350,200)
   love.graphics.print(q.trial_answer,350,250)
end

function question:copy()
   local copy = deepcopy(self)
   copy.params.accuracy = 0
   copy.params.response_time = 10
   copy.params.attempts = {}
   return copy
end

function question:commute()
   -- assert(isCommutative(self.op), 'attempting to commute noncommutative operation')
   local newq = self:copy()
   if isCommutative(self.op) then
      newq.params.terms[2] = self.params.terms[1]
      newq.params.terms[1] = self.params.terms[2]
   else
      newq.params.terms[2] = self.params.terms[3]
      newq.params.terms[3] = self.params.terms[2]
   end
   return newq
end

function question:complement()
   local newq = self:copy()
   newq.params.terms[1] = self.params.terms[3]
   newq.params.terms[3] = self.params.terms[1]
   newq.op = opComplement(self.op)
   return newq
end

function question:incrementTerm(pos)
   local newq = self:copy()
   local p = pos or 1
   newq.params.terms[p] = newq.params.terms[p] + 1
   newq.params.terms[3] = newq.op.func(newq.params.terms[1],newq.params.terms[2])
   return newq
end
   
function question:movePrompt()
   local newq = self:copy()
   newq.free = (self.free+1)%3 + 1
   return newq
end

local modifiers = {question.commute,question.complement,question.incrementTerm,question.movePrompt}

function question:create()
   q = {}
   setmetatable(q,question_mt)
   return q
end


function question:isEqual(q)
   return (self.params.terms[1] == q.params.terms[1] 
              and self.params.terms[2] == q.params.terms[2] 
              and self.params.terms[3] == q.params.terms[3] 
              and self.op.sym == q.op.sym)
end


function question:checkAnswer()
   table.insert(q.attempts,total_attempts)
   local terms = deepcopy(self.params.terms)
   terms[self.free] = self.trial_answer
   local test = tostring(self.op.func(terms[1],terms[2]))
   print('Prev: accuracy = ' .. self.params.accuracy .. ' rt = ' .. self.params.response_time .. '\n')
   if test == tostring(terms[3]) then
      tr = love.timer.getTime() - timer
      self.params.response_time = math.min(10,self.params.response_time + alpha*(tr - self.params.response_time))
      self.params.accuracy = self.params.accuracy + alpha*(1-self.params.accuracy)
      print('New: accuracy = ' .. self.params.accuracy .. ' rt = ' .. self.params.response_time .. '\n')
      return 1
   else
      self.params.accuracy = self.params.accuracy + alpha*(-self.params.accuracy)
      print('New: accuracy = ' .. self.params.accuracy .. ' rt = ' .. self.params.response_time .. '\n')
      return 0
   end
end

function question:computeWeight()
   local last_try = self.attempts[#self.attempts]
   local c1 = 14
   local tr = math.max(self.params.response_time,0.51)
   --local f1 = math.min(1/4, math.exp(-c3/(self.params.response_time*(1.01 - self.params.accuracy))))
   local f1 = math.min(1/4, math.exp(-c1/(tr-0.5)))
   return math.min(f1, 0.1*(total_attempts - last_try)*f1)
end

function question:getNewParams(pdb)
   return function ()
      self.params = pdb.getNewQuestion()
      end
end

function question:wait_for_input(t)
   t = t or math.huge
   return function () self.wait_for_input = true return t end
end

function question:pause_on_correct(t)
   t = t or math.huge
   return function () self.wait_for_input = nil return t end
end

      
function param_db:isValid(question)
   for _, q in ipairs(self) do
      if question.isEqual(question,q) then
         return false
      end
   end
   for _, t in ipairs(question.params.terms) do
      if tonumber(t) < 0 then
         return false
      end
   end
   local lhs = tostring(question.op.func(question.params.terms[1],question.params.terms[2]))
   local rhs = tostring(question.params.terms[3])
   assert(lhs == rhs, 'question is unbalanced, lhs '  .. lhs .. ' rhs ' .. rhs)
   return true
end


function param_db:queryTerms(positions,min_success)
   local min_success = min_success or 0
   local position =  positions or {1,2,3}
   local terms = {}
   for _, v in pairs(param_db) do
      if v.correct/v.attempts > min_success then
         for _, p in ipairs(position) do
            table.insert(terms,v.params.terms[j])
         end
      end
   end  
   return terms
end

function param_db:getNewQuestion()
   local prototype
   while not prototype do
      prototype = self:selectRandomByWeight()
   end
   local valid = false
   while not valid do
      for i, fun in ipairs(modifiers) do
         if math.random() < weights[i] then
            prototype = fun(prototype)
         end
      end
      valid = self:isValid(prototype)
   end
   table.insert(self,prototype)
   return prototype
end

function param_db:getRandomQuestion()
   return self[math.random(#self)]
end

function param_db:selectRandomByWeight()
   local cum = 0
   local trial = math.random()
   local quest = nil
   for _, q in ipairs(self) do
      cum = cum + q:computeWeight()
      print('weight ' .. q:computeWeight() .. ' trial ' .. trial .. ' cum ' .. cum)
      if cum > trial then 
         quest = q
         break 
      end
   end
   if not quest then
      print("new question")
      quest = self:getNewQuestion()
   end
   return quest
end
