



function game_init()

   qdb = initialiseQuestionDB()
  
   q = questioner:init(qdb)
   
   alpha = 0.5

   borders = {
      xMin = 0,
      xMax = love.window.getWidth(),
      yMin = 0,
      yMax = love.window.getHeight()
   }
   
   l_stick = stick:create(50,200,1)
   r_stick = stick:create(750,200,-1)
   ball = ball:create()
  
   table.insert(r_stick.actions,r_stick:waitForBall())
   table.insert(r_stick.actions,r_stick:seekBall())
   
   ball:addObserver(l_stick)
   ball:addObserver(r_stick)
   ball:addObserver(q)
   
   q:addObserver(l_stick)
   q:addObserver(q)

   game_objects = {q,ball,l_stick,r_stick}

end

