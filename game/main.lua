love.graphics.setDefaultFilter("nearest", "nearest")

dicetile = 1

local spawnpoints = {}


local rollSounds = {
	love.audio.newSource("assets/sfx/roll-bounce-1.wav", "static"),
	love.audio.newSource("assets/sfx/roll-bounce-2.wav", "static"),
	love.audio.newSource("assets/sfx/roll-bounce-3.wav", "static"),
	love.audio.newSource("assets/sfx/roll-bounce-4.wav", "static"),
	love.audio.newSource("assets/sfx/roll-bounce-5.wav", "static"),
}

local collectSound = love.audio.newSource("assets/sfx/dice_pickup-bounce-1.wav", "static")
local upgradeSound = love.audio.newSource("assets/sfx/dice_upgrade-bounce-2.wav", "static")

local gameState = "MENU"

local menuBackground = love.graphics.newImage("assets/menu_background.png")
menuBackground:setWrap("repeat", "repeat")
	local menuBackgroundQuad = love.graphics.newQuad(0, 0, 640, 360, 640, 384)
	local menuCursorPos = 1
	local won = false
	
	local music_menu = love.audio.newSource("assets/music_menu.mp3", "stream")
	music_menu:setLooping(true)
	music_menu:play()
	
	local music_main = love.audio.newSource("assets/music_main.mp3", "stream")
	music_main:setLooping(true)
	

	GameWidth, GameHeight = 640, 360
	
	Batteries = require("lib.batteries")
	CPML = require("lib.cpml")
	Class = require("lib.middleclass")
	Peachy = require("lib.peachy")
	Flux = require("lib.flux")
	Utils = require("src.utils")
	Vec3 = Batteries.vec3
	Vec2 = Batteries.vec2
	
	SheetLoader = require("src.sheetLoader")
	Scheduler = require("src.scheduler")
	TDRenderer = require("src.tdrenderer")
	
	local World = require("src.world")
	local DicePanel = require("src.objects.dicePanel")
	local DiceRoller = require("src.objects.diceRoller")
	local StandingSprite = require("src.objects.standingSprite")
	local InfoPanel = require("src.objects.infoPanel")
	infoPanel = InfoPanel()
	
	local Dice = require("src.data.dice")
	local DiceSheet = SheetLoader:loadSheet("assets/dice.png", require("assets.dice"))
	local CrosshairSheet = SheetLoader:loadSheet("assets/crosshairs.png", require("assets.crosshairs"))
	
	local FlatSprite = require("src.objects.flatSprite")
local FontTitle = love.graphics.newFont("assets/FutilePro.ttf", 48)
local FontMenuItems = love.graphics.newFont("assets/FutilePro.ttf", 32)
local FontSmall = love.graphics.newFont("assets/FutilePro.ttf", 16)

local Tilemap = SheetLoader:loadSheet("assets/tilemap.png", require("assets.tilemap"))
local Cards = SheetLoader:loadSheet("assets/cards.png", require("assets.cards"))
local Crosshairs = SheetLoader:loadSheet("assets/crosshairs.png", require("assets.crosshairs"))
local Meeple = SheetLoader:loadSheet("assets/meeple.png", require("assets.meeple"))

local menuData = { hideProgress = 0, transitioning = false }
local function hide()
	Scheduler:waitForFlux(Flux.to(menuData, 1, { hideProgress = 1 }):ease("quadout"))
end

local function show()
	Scheduler:waitForFlux(Flux.to(menuData, 1, { hideProgress = 0 }):ease("quadout"))
end

function transition(newState)
	music_menu:stop()
	music_main:stop()

	menuData.transitioning = true
	Scheduler:waitFor(hide)

	local s = love.timer.getTime()
	while (love.timer.getTime() - s < 1) do
		coroutine.yield()
	end
	gameState = newState

	if (newState == "GAME") then
		music_main:play()
	else
		music_menu:play()
	end

	Scheduler:waitFor(show)
	menuData.transitioning = false
end

local UICanvas = love.graphics.newCanvas(GameWidth, GameHeight)

local dicePanel = DicePanel()
local diceRoller = DiceRoller()
World:build(30, 30)

local turn = 0

local Camera = {
	position = Vec3(20 * 32, 16 * 32, -500),
	realPosition = Vec3(20 * 32, 16 * 32, -500),
	rotation = Vec2(-math.pi, 0),
	projection = CPML.mat4.from_ortho(
		-GameWidth / 2, GameWidth / 2,
		-GameHeight / 2, GameHeight / 2,
		0.1, 1000
	),

	target = World.player,

	update = function(self, dt)
		local position = self.realPosition

		local targetPosition = self.target.position:copy()
		targetPosition.x = math.floor(-targetPosition.x * 3 + 0.5) / 3
		targetPosition.y = math.floor(-targetPosition.y * 3 + 0.5) / 3
		targetPosition.z = position.z

		local newPosition = Vec3(0, 0, 0)
		local lerpSpeed = 1 - 0.002 ^ dt
		newPosition.x = Utils:lerp(position.x, targetPosition.x, lerpSpeed)
		newPosition.y = Utils:lerp(position.y, targetPosition.y, lerpSpeed)
		newPosition.z = targetPosition.z

		self.realPosition:vset(newPosition)

		self.position.x = math.floor(self.realPosition.x + 0.5)
		self.position.y = math.floor(self.realPosition.y + 0.5)
		self.position.z = self.realPosition.z
	end
}

local SunStart = Vec3(-123.802, 0, -223.610)
local Sun = {
	position = SunStart,
	rotation = Vec2(-15.337, 0.3),
	projection = CPML.mat4.from_ortho(
		-GameWidth / 2, GameWidth / 2,
		-GameHeight / 2, GameHeight / 2,
		0.1, 1000
	)
}

local inputBuffer = {
	waiting = false,
	input = nil
}
local function getInput()
	inputBuffer.waiting = true
	inputBuffer.input = nil

	while (not inputBuffer.input) do
		coroutine.yield()
	end

	inputBuffer.waiting = false

	return inputBuffer.input
end

local state
local states = {}

local unlockable = { 2, 3, 4, 6}
local availableDice = {
	{
		kind = Dice[5],
		level = 1,
	},
	{
		kind = Dice[1],
		level = 1,
	}
}
local upgradeable = { availableDice[1], availableDice[2] }

local diceIndex = 1
function states.roll()
	diceIndex = Utils:wrap(diceIndex - 1, 1, #availableDice)
	local selectedDice = availableDice[diceIndex]
	Scheduler:waitForP(dicePanel:show(selectedDice.kind, selectedDice.kind.levels[selectedDice.level]))

	while (true) do
		local input = Scheduler:waitFor(getInput)

		if (input == "a" or input == "left") then
			diceIndex = Utils:wrap(diceIndex - 1, 1, #availableDice)
			local selectedDice = availableDice[diceIndex]
			Scheduler:waitForP(dicePanel:changeLeft(selectedDice.kind, selectedDice.kind.levels[selectedDice.level]))
		end

		if (input == "d" or input == "right") then
			diceIndex = Utils:wrap(diceIndex + 1, 1, #availableDice)
			local selectedDice = availableDice[diceIndex]
			Scheduler:waitForP(dicePanel:changeRight(selectedDice.kind, selectedDice.kind.levels[selectedDice.level]))
		end

		if (input == "space") then
			break
		end
	end

	local toRoll = {}
	local rolled = {}

	local selectedDice = availableDice[diceIndex]
	local diceSet = selectedDice.kind.levels[selectedDice.level]
	for i = 1, #diceSet do
		local diceData = {
			sprite = StandingSprite(DiceSheet.image, DiceSheet.quads.value_zero, Vec3(0, 0, 0), 0),
			offset = 0,
			result = nil,
			options = diceSet[i],
		}

		table.insert(toRoll, diceData)
		Scheduler:waitForP(World.player:addDice(diceData))
	end

	dicePanel:hide()

	while (#toRoll > 0) do
		local input = Scheduler:waitFor(getInput)

		if (input == "space") then
			local i = love.math.random(1, #rollSounds)
			rollSounds[i]:setPitch(love.math.random(95, 100) / 100)
			rollSounds[i]:play()

			local toAdd = 0

			for _, diceData in ipairs(toRoll) do
				local options = diceData.options
				local i = love.math.random(1, #options)
				local result = options[i]

				diceData.result = result
				table.insert(rolled, diceData)
				diceData.sprite:setQuad(result.quad)

				toAdd = toAdd + result.rerolls
			end

			toRoll = {}

			for i = 1, toAdd do
				local diceSet = Dice[diceIndex].levels[1]
				for j = 1, #diceSet do
					local diceData = {
						sprite = StandingSprite(DiceSheet.image, DiceSheet.quads.value_zero, Vec3(0, 0, 0), 0),
						offset = 0,
						result = nil,
						options = diceSet[j],
					}

					table.insert(toRoll, diceData)
					Scheduler:waitForP(World.player:addDice(diceData))
				end
			end
		end
	end

	do
		local waitTime = 0.5
		local start = love.timer.getTime()
		while (love.timer.getTime() - start < waitTime) do
			coroutine.yield()
		end
	end

	Scheduler:waitForP(World.player:collapseDice())

	-- do
	-- 	local waitTime = 0.1
	-- 	local start = love.timer.getTime()
	-- 	while (love.timer.getTime() - start < waitTime) do
	-- 		coroutine.yield()
	-- 	end
	-- end

	local sum = 0
	for _, rolledDice in ipairs(rolled) do
		sum = sum * rolledDice.result.multiplier
		sum = sum + rolledDice.result.value
	end

	if (sum > 99) then sum = 99 end

	World.player:showResultDice(sum)
	-- local roll = diceRoller:roll(Dice[6], 1)
	-- while (not roll.done) do
	-- 	coroutine.yield()
	-- end

	-- -- local changeLeft = dicePanel:changeLeft(Dice[6], 1)
	-- -- while (not changeLeft.done) do
	-- -- 	coroutine.yield()
	-- -- end

	-- -- local roll = diceRoller:roll(Dice[6], 1)
	-- -- while (not roll.done) do
	-- -- 	coroutine.yield()
	-- -- end





	state = Scheduler:enqueue(states.move, sum)
end

function states.move(actionAmount)
	-- World.player.actions:setShowIndicators(true)
	World.player.turnsLeft = actionAmount

	while (World.player.turnsLeft > 0) do
		coroutine.yield()
	end

	do
		local waitTime = 0.2
		local start = love.timer.getTime()
		while (love.timer.getTime() - start < waitTime) do
			coroutine.yield()
		end
	end
	Scheduler:waitForP(World.player:hideResultDice())

	do
		local tilePosition = Utils:vWorldToTile(World.player.position)

		local yes = false
		if (dicetile == 1 and tilePosition.x == 16 and tilePosition.y == 16) then
			yes = true
		end
		if (dicetile == 2 and tilePosition.x == 37 and tilePosition.y == 16) then
			yes = true
		end
		if (dicetile == 3 and tilePosition.x == 16 and tilePosition.y == 32) then
			yes = true
		end
		if (dicetile == 4 and tilePosition.x == 37 and tilePosition.y == 32) then
			yes = true
		end

		if (yes) then
			local collect = false
			local name = nil

			if (#unlockable > 0 and love.math.random() > 0.3) then
				local i = love.math.random(1, #unlockable)
				local dice = Dice[unlockable[i]]

				local d = {
					kind = dice,
					level = 1,
				}
				local j = table.insert(availableDice, d)

				table.insert(upgradeable, d)
				table.remove(unlockable, i)

				name = dice.name

				collectSound:play()
			else
				if (#upgradeable > 0) then
					local i = love.math.random(1, #upgradeable)
					local dice = upgradeable[i]

					dice.level = dice.level + 1
					if (dice.level == #dice.kind.levels) then
						table.remove(upgradeable, i)
					end

					name = dice.kind.name
					collect = true

					upgradeSound:play()
				end
			end

			if (name) then
				Scheduler:waitForP(infoPanel:show(not collect, name))
				while (true) do
					local input = Scheduler:waitFor(getInput)
					if (input == "space") then
						break
					end
				end
				Scheduler:waitForP(infoPanel:hide())
			end

			if (name) then
				local options = {}
				for i = 1, 4 do
					if (i ~= dicetile) then
						table.insert(options, i)
					end
				end

				local j = love.math.random(1, #options)
				dicetile = options[j]
			end

			if (#upgradeable == 0 and #unlockable == 0) then
				dicetile = 0
			end
		end
	end

	

	state = Scheduler:enqueue(states.enemiesTurn)
end

function states.enemiesTurn()
	local enemies = {}
	for _, enemy in ipairs(World.enemies) do
		table.insert(enemies, enemy)
	end

	for _, enemy in ipairs(enemies) do
		Scheduler:waitForP(enemy:performTurn())
	end

	for _, spawnpoint in ipairs(spawnpoints) do
		World:spawnEnemy(spawnpoint.position)
	end
	spawnpoints = {}

	local doSpawn = turn % 1 == 0
	if (doSpawn) then
		local x, y
		while (true) do
			x = love.math.random(13, 40)
			y = love.math.random(13, 35)

			if (not World.occupationMap:atOfType(Vec2(x, y), "isWall")) then
				break
			end
		end

		local worldX, worldY = Utils:tileToWorld(x, y)

		table.insert(spawnpoints, {
			image = FlatSprite(CrosshairSheet.image, CrosshairSheet.quads.spawn, Vec3(worldX, worldY, 0.01), 0),
			position = Vec2(worldX, worldY)
		})
	end

	turn = turn + 1

	state = Scheduler:enqueue(states.roll)
end

Scheduler:enqueue(states.roll)

function love.load()
end

function love.update(dt)
	Sun.position = SunStart:sadd(Camera.position.x + 64, Camera.position.y + 64, 0)

	Flux.update(dt)
	Scheduler:update()

	if (gameState == "MENU") then

	end

	if (gameState == "GAME") then
		World:update(dt)
		dicePanel:update(dt)
		Camera:update(dt)
	end
end

function love.draw()
	if (gameState == "GAME") then
		World:draw()
		for _, spawnpoint in ipairs(spawnpoints) do
			spawnpoint.image:draw()
		end
		TDRenderer:flush(Camera, Sun)
	end

	love.graphics.setCanvas(UICanvas)
	love.graphics.clear(0, 0, 0, 0)

	if (gameState == "DEAD") then
		local p = -love.timer.getTime() * 16
		menuBackgroundQuad:setViewport(-p, -p + math.sin(love.timer.getTime()) * 32, 640, 360, 640, 384)
		love.graphics.draw(menuBackground, menuBackgroundQuad, 0, 0)
		love.graphics.setFont(FontTitle)
		love.graphics.printf("Rolldown", 0, 16 + math.sin(love.timer.getTime()) * 8, 640, "center")

		if (won) then
			love.graphics.printf("You win!", 0, 90, 640, "center")
		else
			love.graphics.printf("You lose...", 0, 90, 640, "center")
		end

		love.graphics.setFont(FontMenuItems)
		love.graphics.printf("Play Again", 0, 160, 640, "center")
		love.graphics.printf("Quit", 0, 200, 640, "center")

		local o = math.sin(love.timer.getTime() * 5) * 4 - 5
		if (menuCursorPos == 1) then
			love.graphics.print(">", 220 + o, 160)
		elseif (menuCursorPos == 2) then
			love.graphics.print(">", 272 + o, 200)
		end

		love.graphics.setFont(FontSmall)
		love.graphics.printf([[
Code
Art
Audio

GMTK Game Jam 2022
Roll of the Dice
		]], 5, 268, 640, "left")

		love.graphics.printf([[
Keyslam
Josh Perry
Speak
					]], 5, 268, 140, "right")
	end

	if (gameState == "MENU") then
		local p = -love.timer.getTime() * 16
		menuBackgroundQuad:setViewport(-p, -p + math.sin(love.timer.getTime()) * 32, 640, 360, 640, 384)
		love.graphics.draw(menuBackground, menuBackgroundQuad, 0, 0)
		love.graphics.setFont(FontTitle)
		love.graphics.printf("Rolldown", 0, 16 + math.sin(love.timer.getTime()) * 8, 640, "center")

		love.graphics.setFont(FontMenuItems)
		love.graphics.printf("Play", 0, 120, 640, "center")
		love.graphics.printf("Settings", 0, 160, 640, "center")
		love.graphics.printf("Quit", 0, 200, 640, "center")

		local o = math.sin(love.timer.getTime() * 5) * 4 - 5
		if (menuCursorPos == 1) then
			love.graphics.print(">", 270 + o, 120)
		elseif (menuCursorPos == 2) then
			love.graphics.print(">", 238 + o, 160)
		elseif (menuCursorPos == 3) then
			love.graphics.print(">", 272 + o, 200)
		end

		love.graphics.setFont(FontSmall)
		love.graphics.printf([[
Code
Art
Audio

GMTK Game Jam 2022
Roll of the Dice
		]], 5, 268, 640, "left")

		love.graphics.printf([[
Keyslam
Josh Perry
Speak
					]], 5, 268, 140, "right")
	end

	if (gameState == "GAME") then
		dicePanel:draw()
		infoPanel:draw()
	end

	love.graphics.setCanvas()

	love.graphics.draw(UICanvas, 0, 0, 0, love.graphics.getWidth() / GameWidth, love.graphics.getHeight() / GameHeight)

	if (menuData.transitioning) then
		love.graphics.setColor(0, 0, 0, 1)
		local w = love.graphics.getWidth() * menuData.hideProgress
		love.graphics.rectangle("fill", 0, 0, w, love.graphics.getHeight())
		love.graphics.setColor(1, 1, 1, 1)
	end
end

function love.quit()

end

function love.keypressed(key, scancode, isrepeat)
	if (menuData.transitioning) then
		return
	end

	if (gameState == "GAME") then
		World:keypressed(key)

		if (inputBuffer.waiting) then
			inputBuffer.input = key
		end
	end

	if (gameState == "MENU") then
		if (key == "w" or key == "up") then
			menuCursorPos = Utils:wrap(menuCursorPos - 1, 1, 3)
		end

		if (key == "s" or key == "down") then
			menuCursorPos = Utils:wrap(menuCursorPos + 1, 1, 3)
		end

		if (key == "space") then
			if (menuCursorPos == 1) then
				Scheduler:enqueue(transition, "GAME")
			end

			if (menuCursorPos == 3) then
				love.event.quit()
			end
		end
	end

	if (gameState == "DEAD") then
		if (key == "w" or key == "up") then
			menuCursorPos = Utils:wrap(menuCursorPos - 1, 1, 2)
		end

		if (key == "s" or key == "down") then
			menuCursorPos = Utils:wrap(menuCursorPos + 1, 1, 2)
		end

		if (key == "space") then
			if (menuCursorPos == 1) then
				love.event.quit("restart")
			end

			if (menuCursorPos == 2) then
				love.event.quit()
			end
		end
	end
end

function love.keyreleased(key, scancode)

end
