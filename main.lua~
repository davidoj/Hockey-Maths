
--debug = true

require "phys"
require "maths"
require "objects"

function love.load(arg)
   
   love.keyboard.setKeyRepeat( disable )

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
         l_stick.y = Predict(l_stick,ball,1)
      end
   end
   
end
   

function love.update(dt)
   
   ball:update(dt)
   l_stick:update(dt)
   r_stick:update(dt)

   local wc,tc,sc = WallCollision(ball,borders), ObjectCollision(ball,l_stick)

   if tc<dt and tc>=0 and sc then
      ReflectFromSurface(ball,cId2ccode(sc))
   end
   if wc then
      ReflectFromSurface(ball,wc)
   end   

   if love.keyboard.isDown('w') then
      l_stick.ydot = -300
   elseif love.keyboard.isDown('a') then
      l_stick.xdot = -300
   elseif love.keyboard.isDown('s') then
      l_stick.ydot = 300
   elseif love.keyboard.isDown('d') then
      l_stick.xdot = 300
   else l_stick.xdot, l_stick.ydot = 0, 0
   end
   if love.keyboard.isDown('q') then
      l_stick.thetadot = -10
   elseif love.keyboard.isDown('e') then
      l_stick.thetadot = 10
   else l_stick.thetadot = 0
   end

end


function love.draw(dt)
   love.graphics.print(question:toString(),200,200)
   love.graphics.print(ans,200,250)
   for _, obj in ipairs({l_stick,r_stick,ball}) do
      draw_object(obj)
      love.graphics.polygon('line',obj.vertices)
   end
end
