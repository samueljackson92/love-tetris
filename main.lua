----------------------------
--SUPER GLOBALS
----------------------------
--stuff that will need to be accessed by other files goes in here
DrawList = {}
Game = {}
Game.height = 690
Game.width = 320
Game.score = 0
Game.speed = 1
Game.lineCount = 0
Game.nextIncreatment = 5
Game.displayMenu = true
Game.paused = false
Game.EOG = false

----------------------------
--Requirements
----------------------------
require "shape"

----------------------------
--Main.lua Globals
----------------------------
tmr = 0

function love.load()
	love.graphics.setCaption("Tetris")
	love.graphics.setBackgroundColor(104, 136, 248)
	love.graphics.setMode(Game.width, Game.height, false, true, 0)
	love.graphics.setColorMode( "replace")
	
	currentBlock = Shape:new()
	currentBlock:initShape()
end

function love.update(dt)
	math.randomseed(os.time() + dt)
	tmr = tmr + dt

	if Game.paused == false and Game.EOG == false then
	
		if tmr >= Game.speed then
			if currentBlock:checkHitFloor() == false and checkHitBlock() == false then
				currentBlock:down()
				tmr = 0
			else
				makeNewBlock()
			end
		end
		
		local linesThisDelta = checkLine()
		Game.lineCount = Game.lineCount + linesThisDelta
		Game.EOG = checkGameOver()
		Game.score = Game.score + (linesThisDelta * 10)
		
		if Game.lineCount >= Game.nextIncreatment and linesThisDelta ~= 0 then
			Game.speed = Game.speed - 0.1
			local r = Game.lineCount % 5
			Game.nextIncreatment = (Game.lineCount - r) + 5
		end		
	end
end

function love.draw()
	currentBlock:draw()
	for i,v in ipairs(DrawList) do
		v:draw()
	end
	
	--Draw the menus and HUD
	if Game.displayMenu ==  true then
		Game.paused = true
		showMenu()
	elseif Game.displayMenu == false and Game.paused ==  true then
		showPauseScreen()
	end
	
	if Game.EOG == true then
		showGameOver()
	end
	
	showHUD()
end

function love.keypressed(e)
	if e == "escape" then
		love.event.push("q")
	end
	
	if currentBlock:checkHitWall(e) == false then
		currentBlock:move(e)
	end
	
	if e == "down" then
		if currentBlock:checkOnScreen() == true then
			local flag = false
			while flag == false do
				if currentBlock:checkHitFloor() == false and checkHitBlock() == false then
					currentBlock:down()
				else
					makeNewBlock()
					flag = true
				end
			end
		end
	end
	
	if e == "up" then
		currentBlock:rotate()
	end
	

	if Game.paused == true or Game.displayMenu ==  true or Game.EOG == true then
		if e == "n" then
			newGame()
		end
	end
	
	if e == "f1" then
		if Game.paused == true then
			Game.paused = false
		else
			Game.paused = true
		end
	end
end

----------------------------------------------------------
--Non Love Functions
----------------------------------------------------------

function checkHitBlock()
	for i,v in ipairs(DrawList) do
		for j,w in ipairs(currentBlock.blockArray) do
			if w.row + 1 == v.row and w.coll == v.coll then
				return true
			end
		end
	end
	return false
end


function makeNewBlock()
	for i,v in ipairs(currentBlock.blockArray) do
		table.insert(DrawList, v)
	end
	currentBlock = Shape:new()
	currentBlock:initShape()
end

function checkLine()
	local noOfLines = 0
	local lineCount = 0
	local lineVals = {}
	local aboveVals = {}
	
	for i = 1, 20 do
		for j,v in ipairs(DrawList) do
			if v.row == i then
				lineCount = lineCount + 1
				table.insert(lineVals, j)
			elseif v.row < i then
				table.insert(aboveVals, v)
			end
		end
		
		if lineCount == 10 then
			for j,v in ipairs(lineVals) do
				table.remove(DrawList, v - j + 1)
			end
			for j,v in ipairs(aboveVals) do
				v:setTableVal(v.coll, v.row + 1)
			end
			noOfLines = noOfLines + 1
		end
		
		lineCount = 0
		lineVals = {}
		aboveVals = {}
	end
	return noOfLines
end

function checkGameOver()
	for i,v in ipairs(DrawList) do
		if v.row <= 1 then
			return true
		end
	end
	return false
end


function showMenu()
	love.graphics.setColor(0, 0, 0, 220)
	love.graphics.rectangle("fill", 0, 0, 320, 640 )
	love.graphics.printf("TETRIS" , 80, 160, 150, "center")
	love.graphics.printf("By Samuel Jackson" , 80, 180, 150, "center")
	love.graphics.printf("Press N to make a New Game" , 60, 250, 200, "center")
	love.graphics.printf("Press F1 at any time to pause" , 60, 270, 200, "center")
end

function showPauseScreen()
	love.graphics.setColor(0, 0, 0, 220)
	love.graphics.rectangle("fill", 0, 140, 320, 50 )
	love.graphics.printf("Game Paused", 80, 160, 150, "center")
	love.graphics.printf("N for new game. F1 to Un-pause" , 60, 180, 200, "center")
end

function showGameOver()
	love.graphics.setColor(0, 0, 0, 220)
	love.graphics.rectangle("fill", 0, 140, 320,  80 )
	love.graphics.printf("Game Over" , 80, 160, 150, "center")
	love.graphics.printf("Your Score was: " .. Game.score , 60, 180, 200, "center")
	love.graphics.printf("N for new game. F1 to Un-pause" , 60, 200, 200, "center")
end

function showHUD()
	love.graphics.setColor(0, 0, 0, 220)
	love.graphics.rectangle("fill", 0, 640, 320, 50 )
	love.graphics.printf("Score: " .. Game.score , 10, 670, 80, "left")
	love.graphics.printf("Speed: " .. Game.speed .. "s" , 80, 670, 80, "left")
end

function newGame()
	DrawList = {}
	currentBlock = Shape:new()
	currentBlock:initShape()
	Game.speed = 1
	Game.score = 0
	Game.EOG = false
	Game.paused = false
	Game.displayMenu = false
end
