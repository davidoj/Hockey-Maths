
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


question = {
   terms = {'1','1','2'},
   op = opPlus,
   accuracy = 0,
   response_time = 10,
   attempts = {},
   free = 1
}

question_mt = { __index = question }



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

function question:copy()
   local copy = deepcopy(self)
   copy.accuracy = 0
   copy.response_time = 10
   copy.attempts = {}
   return copy
end

function question:commute()
   -- assert(isCommutative(self.op), 'attempting to commute noncommutative operation')
   local newq = self:copy()
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
   local newq = self:copy()
   newq.terms[1] = self.terms[3]
   newq.terms[3] = self.terms[1]
   newq.op = opComplement(self.op)
   return newq
end

function question:incrementTerm(pos)
   local newq = self:copy()
   local p = pos or 1
   newq.terms[p] = newq.terms[p] + 1
   newq.terms[3] = newq.op.func(newq.terms[1],newq.terms[2])
   return newq
end
   
function question:movePrompt()
   local newq = self:copy()
   newq.free = (self.free+1)%3 + 1
   return newq
end

function question:isEqual(q)
   return (self.terms[1] == q.terms[1] 
              and self.terms[2] == q.terms[2] 
              and self.terms[3] == q.terms[3] 
              and self.op.sym == q.op.sym)
end


function question:computeWeight(total_attempts)
   local last_try = self.attempts[#self.attempts]
   local c1 = 14
   local tr = math.max(self.response_time,0.51)
   --local f1 = math.min(1/4, math.exp(-c3/(self.question.response_time*(1.01 - self.question.accuracy))))
   local f1 = math.min(1/4, math.exp(-c1/(tr-0.5)))
   return math.min(f1, 0.1*(total_attempts - last_try)*f1)
end
