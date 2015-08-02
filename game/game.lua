



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
   l_score = score:init(1)
   r_score = score:init(-1)
  
   table.insert(r_stick.actions,r_stick:waitForBall())
   table.insert(r_stick.actions,r_stick:seekBall())

   game_objects = {q,ball,l_stick,r_stick,l_score,r_score}
   
   ball:addObserver(l_stick)
   ball:addObserver(r_stick)
   ball:addObserver(q)
   ball:addObserver(ball)
   ball:addObserver(l_score)
   ball:addObserver(r_score)
   
   q:addObserver(l_stick)
   q:addObserver(q)
   q:addObserver(ball)
   q:addObserver(r_score)


end

