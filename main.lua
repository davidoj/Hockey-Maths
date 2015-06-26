
--debug = true

require "maths"
require "objects"
require "behaviour"
require "util"
serialize = require 'Ser.ser'

function love.load(arg)
   
   love.keyboard.setKeyRepeat( disable )

   font_lastTime = love.graphics.newFont('art/KGTheLastTime.ttf',35)
   love.graphics.setFont(font_lastTime)
   setupObjectsAndBorders()

   -- if love.filesystem.exists('Questions.lua') then
   --    questions = love.filesystem.load('Questions.lua')
   -- else
   --    questions = {}
   -- end

   q = question_db:getRandomQuestion()
   ans = ''

   table.insert(r_stick.actions,r_stick.waitForBall)
   table.insert(r_stick.actions,r_stick.seekBall)

   total_attempts = 0

   alpha = 0.5

   timer = love.timer.getTime()

end

function love.keypressed(key)
   for _,value in ipairs({'1','2','3','4','5','6','7','8','9','0','-'}) do
      if value == key then
         ans = ans .. key
      end
   end
   if key == 'return' and ans ~= '' then
      q.trial_answer = ans
      local r = q:checkAnswer(ans)
      ans = ''
      table.insert(q.attempts,total_attempts)
      total_attempts = total_attempts + 1
      if r==1 then
         timer = love.timer.getTime()
         q = question_db:getNewQuestion()
         table.insert(l_stick.actions,l_stick.waitForBall)
         table.insert(l_stick.actions,l_stick.seekBall)
      end
   end
   
end
   

function love.update(dt)

   ball:update(dt)
   l_stick:update(dt)
   r_stick:update(dt)


end


function love.draw(dt)
   love.graphics.print(q:toString(),350,200)
   love.graphics.print(ans,350,250)
   for _, obj in ipairs({l_stick,r_stick,ball}) do
      draw_object(obj)
      --love.graphics.polygon('line',obj.vertices)
   end
end



function love.quit()
   --love.filesystem.write('Questions.lua',serialize(questions))
end
