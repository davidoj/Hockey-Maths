--debug = true



function love.load(arg)

   require "questions/question"
   require "questions/question_db"
   require "game/objects"
   require "game/input"
   require "game/behaviour"
   require "game/questioner"
   require "util/util"
   serialize = require 'util/ser'
   
   love.keyboard.setKeyRepeat( disable )

   font_lastTime = love.graphics.newFont('fonts/KGTheLastTime.ttf',35)
   love.graphics.setFont(font_lastTime)
   setupObjectsAndBorders()
   
   qdb = initialiseQuestionDB()

   q = questioner:init(qdb)
   ans = ''
 
   total_attempts = 0

   alpha = 0.5

   timer = love.timer.getTime()

end

function love.keypressed(key)
   if q.wait_for_input then
      handle_question_input(key,q,qdb)
   end

end
   

function love.update(dt)

   ball:update(dt)
   l_stick:update(dt)
   r_stick:update(dt)
   q:update(dt)

end


function love.draw(dt)
   q:display()
   for _, obj in ipairs({l_stick,r_stick,ball}) do
      draw_object(obj)
      --love.graphics.polygon('line',obj.vertices)
   end
end



function love.quit()
   love.filesystem.write('qdb.lua',serialize(qdb))
end


function onBallCollision(ccode) 
   l_stick:update(0,1)
   r_stick:update(0,1)
   q:update(0,1)

   if ccode[1] == 1 then 
      table.insert(r_stick.actions,r_stick.waitForBall)
      table.insert(r_stick.actions,r_stick.seekBall)
   end
   
end
