--debug = true



function love.load(arg)

   require "questions/question"
   require "questions/question_db"
   require "game/objects"
   require "game/stick"
   require "game/ball"
   require "game/game"
   require "game/questioner"
   require "util/util"
   serialize = require 'util/ser'
   
   love.keyboard.setKeyRepeat( disable )

   font_lastTime = love.graphics.newFont('fonts/KGTheLastTime.ttf',35)
   love.graphics.setFont(font_lastTime)
   
   game_init()
 
   timer = love.timer.getTime()

end

function love.keypressed(key)
   q:handleInput(key,qdb)
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

