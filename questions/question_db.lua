require "questions/question"

local question_db = {}
local question_db_mt = { __index = question_db }


local modifiers = {question.commute,question.complement,question.incrementTerm,question.movePrompt}
local weights = {0.5,0.5,0.5,0.5}

function initialiseQuestionDB()
   local qdb
--   if love.filesystem.exists('qdb.lua') then
 --     save_qdb = love.filesystem.load('qdb.lua')
 --     qdb = save_qdb()
 --  else
   qdb = {question}
 --  end
   setmetatable(qdb,question_db_mt)
   return qdb
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
   local lhs = tostring(question.op.func(question.terms[1],question.terms[2]))
   local rhs = tostring(question.terms[3])
   assert(lhs == rhs, 'question is unbalanced, lhs '  .. lhs .. ' rhs ' .. rhs)
   return true
end


function question_db:queryTerms(positions,min_success)
   local min_success = min_success or 0
   local position =  positions or {1,2,3}
   local terms = {}
   for _, v in pairs(question_db) do
      if v.correct/v.attempts > min_success then
         for _, p in ipairs(position) do
            table.insert(terms,v.params.terms[j])
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
         if math.random() < weights[i] then
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

function question_db:selectRandomByWeight(total_attempts)
   local cum = 0
   local trial = math.random()
   local quest = nil
   for _, q in ipairs(self) do
      cum = cum + q:computeWeight(total_attempts)
      print('weight ' .. q:computeWeight(total_attempts) .. ' trial ' .. trial .. ' cum ' .. cum)
      if cum > trial then 
         quest = q
         break 
      end
   end
   if not quest then
      print("new question")
      quest = self:getNewQuestion()
   end
   print(quest)
   return quest
end
