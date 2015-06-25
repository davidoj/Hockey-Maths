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
   terms = {'1','1','2'},
   op = opPlus,
   correct = 0,
   attempts = 0
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
   return (op == '+' or op == '*')
end

function question:commute()
   -- assert(isCommutative(self.op), 'attempting to commute noncommutative operation')
   local newq = deepcopy(self)
   if isCommutative(self.op) then
      newq.terms[2] = self.terms[1]
      newq.terms[1] = self.terms[2]
   end
   return newq
end

function question:complement()
   local pos
   if isCommutative(self.op) then
      pos = 1
   else
      pos = 2
   end
   local newq = deepcopy(self)
   newq.terms[pos] = self.terms[3]
   newq.terms[3] = self.terms[pos]
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

function question_db:newQuestion()
   local prototype = self[math.random(#question_db)]
   for i, fun in ipairs(modifiers) do
      if math.random() > weights[i] then
         prototype = fun(prototype)
      end
   end
   return prototype
end

function question:toString()
   local terms = deepcopy(self.terms)
   terms[self.free] = '_'
   local str = terms[1] .. self.op.sym .. terms[2] .. '=' .. terms[3]
   return str
end

function question:checkAnswer(answer)
   self.attempts = self.attempts + 1
   self.terms[self.free] = answer
   local test  = tostring(self.op.func(self.terms[1],self.terms[2]))
   if test == self.terms[3] then
     
      self.correct = self.correct + 1
      return 1
   else
      return 0
   end
end
