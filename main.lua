
--debug = true

require "phys"
require "maths"
require "objects"
require "behaviour"
require "util"

function love.load(arg)
   
   love.keyboard.setKeyRepeat( disable )

   font_lastTime = love.graphics.newFont('art/KGTheLastTime.ttf',35)
   love.graphics.setFont(font_lastTime)
   setup_objects_and_borders()

   question = create_random_question(Params.ops)
   ans = ''

end

function love.keypressed(key)
   for _,value in ipairs({'1','2','3','4','5','6','7','8','9','0','-'}) do
      if value == key then
         ans = ans .. key
      end
   end
   if key == 'return' then
      question:checkAnswer(ans)
      ans = ''
      if question.correct==1 then
         question = create_random_question(Params.ops)
         table.insert(l_stick.actions,l_stick.wait_for_ball)
         table.insert(l_stick.actions,l_stick.seek_ball)
      end
   end
   
end
   

function love.update(dt)

   
   ball:update(dt)
   l_stick:update(dt)
   r_stick:update(dt)


end


function love.draw(dt)
   love.graphics.print(question:toString(),350,200)
   love.graphics.print(ans,350,250)
   for _, obj in ipairs({l_stick,r_stick,ball}) do
      draw_object(obj)
      --love.graphics.polygon('line',obj.vertices)
   end
end
