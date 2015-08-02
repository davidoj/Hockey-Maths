
function love.load(arg)

   require "questions/question"
   require "questions/question_db"
   require "game/objects"
   require "game/stick"
   require "game/ball"
   require "game/game"
   require "game/questioner"
   require "util/util"
   require "game/score"
   serialize = require 'util/ser'
   
   love.keyboard.setKeyRepeat( disable )

   font_lastTime = love.graphics.newFont('fonts/KGTheLastTime.ttf',35)
   love.graphics.setFont(font_lastTime)
   
   game_init()
 
end

function love.keypressed(key)
   q:handleInput(key,qdb)
end
   

function love.update(dt)

   for _, o in pairs(game_objects) do
      o:update(dt)
   end

end


function love.draw(dt)
   for _, o in pairs(game_objects) do
      o:display()
   end
end



function love.quit()
   love.filesystem.write('qdb.lua',serialize(qdb))
end

