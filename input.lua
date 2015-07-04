function handle_question_input(key,q)
   for _,value in ipairs({'1','2','3','4','5','6','7','8','9','0','-'}) do
      if value == key then
         q.trial_answer = q.trial_answer .. key
      end
   end

   if key == 'backspace' and #ans>0 then
      q.trial_answer = string.sub(q.trial_answer,1,-2)
   end
   
   if key == 'return' and q.trial_answer ~= '' then
      local r = q:checkAnswer(ans)
      q.trial_answer = ''
      table.insert(q.attempts,total_attempts)
      total_attempts = total_attempts + 1
      if r==1 then
         handle_correct_answer()
      end
   end

end


function handle_correct_answer()
   
   --timer = love.timer.getTime()
   table.insert(q.actions,question.pause_on_correct)
   table.insert(q.actions,question.getNewParams)
   q = qdb:selectRandomByWeight()
   table.insert(l_stick.actions,l_stick.waitForBall)
   table.insert(l_stick.actions,l_stick.seekBall)

end
