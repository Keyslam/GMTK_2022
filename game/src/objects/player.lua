local Entity = require("src.objects.entity")
local StandingSprite = require("src.objects.standingSprite")
local MovementIndicator = require("src.objects.movementIndicator")

local dieSound = love.audio.newSource("assets/sfx/metal_hit-bounce-1.wav", "static")
local MoveSounds = {
	love.audio.newSource("assets/sfx/move1-bounce-4.wav", "stream"),
	love.audio.newSource("assets/sfx/move2-bounce-4.wav", "stream"),
}

local Tilemap = SheetLoader:loadSheet("assets/tilemap.png", require("assets.tilemap"))
local Dice = SheetLoader:loadSheet("assets/dice.png", require("assets.dice"))

local Player = Class("Player", Entity)

function Player:initialize(position, occupationMap)
	self.position = position
	self.rotation = 0
	self.occupationMap = occupationMap

	self.sprite = StandingSprite(Tilemap.image, Tilemap.quads.player, self.position, self.rotation)

	self.turnsLeft = 0
	self.moving = false

	self.occupationMap:add(self, Utils:vWorldToTile(self.position))

	self.indicators = {
		up = MovementIndicator(self.position),
		down = MovementIndicator(self.position),
		left = MovementIndicator(self.position),
		right = MovementIndicator(self.position),
	}
	self.showIndicators = true

	self.diceStack = {}

	self.resultDice = {}

	self:updateMovementIndicators()

	self.isPlayer = true
end

function Player:updateMovementIndicators()
	self.indicators.up.position = self.position:sadd(0, 32, 0.01)
	self.indicators.down.position = self.position:sadd(0, -32, 0.01)
	self.indicators.left.position = self.position:sadd(-32, 0, 0.01)
	self.indicators.right.position = self.position:sadd(32, 0, 0.01)
end

function Player:update(dt)
	
end

local function addDice(self, diceData)
	table.insert(self.diceStack, 1, diceData)

	local done = false
	for i, oDice in ipairs(self.diceStack) do
		local newOffset = oDice.offset + 18
		if i == 1 then
			newOffset = oDice.offset + 30
		end
		local f = Flux.to(oDice, 0.3, {offset = newOffset})
		:ease("quadout")
		if (i == 1) then
			f:oncomplete(function()
				done = true
			end)
		end
	end

	while (not done) do
		coroutine.yield()
	end
end

function Player:addDice(diceData)
	return Scheduler:enqueue(addDice, self, diceData)
end

local function collapseDice(self)
	local done = false
	local c = #self.diceStack
	for i, oDice in ipairs(self.diceStack) do
		local newOffset = 30
		local f = Flux.to(oDice, c > 1 and 0.2 or 0, {offset = newOffset})
		:ease("quadout")
		if (i == 1) then
			f:oncomplete(function()
				done = true
			end)
		end
	end

	while (not done) do
		coroutine.yield()
	end

	self.diceStack = {}
end

function Player:collapseDice()
	return Scheduler:enqueue(collapseDice, self)
end

function Player:showResultDice(value)
	self.resultDice = {}

	if (value > 9) then
		do
			local quad = Dice.quads.value_zero

			local l = math.floor(value / 10)
			if (l == 0) then quad = Dice.quads.value_left_zero end
			if (l == 1) then quad = Dice.quads.value_left_one end
			if (l == 2) then quad = Dice.quads.value_left_two end
			if (l == 3) then quad = Dice.quads.value_left_three end
			if (l == 4) then quad = Dice.quads.value_left_four end
			if (l == 5) then quad = Dice.quads.value_left_five end
			if (l == 6) then quad = Dice.quads.value_left_six end
			if (l == 7) then quad = Dice.quads.value_left_seven end
			if (l == 8) then quad = Dice.quads.value_left_eight end
			if (l == 9) then quad = Dice.quads.value_left_nine end

			table.insert(self.resultDice, {
				offsetX = -4,
				offsetZ = 30,
				quad = quad,
				sprite = StandingSprite(Dice.image, quad, Vec3(0, 0, 0), 0),
			})
		end

		do
			local quad = Dice.quads.value_zero

			local l = value % 10
			if (l == 0) then quad = Dice.quads.value_right_zero end
			if (l == 1) then quad = Dice.quads.value_right_one end
			if (l == 2) then quad = Dice.quads.value_right_two end
			if (l == 3) then quad = Dice.quads.value_right_three end
			if (l == 4) then quad = Dice.quads.value_right_four end
			if (l == 5) then quad = Dice.quads.value_right_five end
			if (l == 6) then quad = Dice.quads.value_right_six end
			if (l == 7) then quad = Dice.quads.value_right_seven end
			if (l == 8) then quad = Dice.quads.value_right_eight end
			if (l == 9) then quad = Dice.quads.value_right_nine end

			table.insert(self.resultDice, {
				offsetX = 4,
				offsetZ = 30,
				quad = quad,
				sprite = StandingSprite(Dice.image, quad, Vec3(0, 0, 0), 0),
			})
		end
	else
		local quad = Dice.quads.value_zero

		if (value == 0) then quad = Dice.quads.value_zero end
		if (value == 1) then quad = Dice.quads.value_one end
		if (value == 2) then quad = Dice.quads.value_two end
		if (value == 3) then quad = Dice.quads.value_three end
		if (value == 4) then quad = Dice.quads.value_four end
		if (value == 5) then quad = Dice.quads.value_five end
		if (value == 6) then quad = Dice.quads.value_six end
		if (value == 7) then quad = Dice.quads.value_seven end
		if (value == 8) then quad = Dice.quads.value_eight end
		if (value == 9) then quad = Dice.quads.value_nine end

		table.insert(self.resultDice, {
			offsetX = 0,
			offsetZ = 30,
			quad = quad,
			sprite = StandingSprite(Dice.image, quad, Vec3(0, 0, 0), 0),
		})
	end
end

local function hideResultDice(self)
	local done = false
	for i, oDice in ipairs(self.resultDice) do
		local f = Flux.to(oDice, 0.1, {offsetZ = 0})
		:ease("quadout")
		if (i == 1) then
			f:oncomplete(function()
				done = true
			end)
		end
	end

	while (not done) do
		coroutine.yield()
	end

	self.resultDice = {}
end

function Player:hideResultDice(value)
	return Scheduler:enqueue(hideResultDice, self, value)
end

function Player:draw()
	self.sprite:setPosition(self.position)
	self.sprite:setRotation(self.rotation)

	self.sprite:draw()

	for i, diceData in ipairs(self.diceStack) do
		diceData.sprite:setPosition(self.position:sadd(0, 0.1 + (i * 0.01), diceData.offset + 2))
		diceData.sprite:draw()
	end

	for _, diceData in ipairs(self.resultDice) do
		diceData.sprite:setPosition(self.position:sadd(diceData.offsetX, 0.1, diceData.offsetZ + 2))
		diceData.sprite:draw()
	end

	if (not self.moving and self.turnsLeft > 0) then
		self.indicators.up:draw()
		self.indicators.down:draw()
		self.indicators.left:draw()
		self.indicators.right:draw()
	end
end

local function moveTo(self, targetPosition, rotation, time)
	local startPosition = self.position:copy()
	local startRotation = self.rotation

	local main = Flux.to(self.position, time, {x = targetPosition.x, y = targetPosition.y}):ease("quadout")
	Flux.to(self.position, time * 0.5, {z = startPosition.z + 15}):ease("quadout")
	:oncomplete(function()
		Flux.to(self.position, time * 0.5, {z = startPosition.z}):ease("quadout")
	end)

	local targetTilePosition = Utils:vWorldToTile(targetPosition)
	while (true) do
		local tilePosition = Utils:vWorldToTile(targetPosition)
		if (tilePosition.x == targetTilePosition.x and tilePosition.y == targetTilePosition.y) then
			if (self.occupationMap:atOfType(tilePosition, "isEnemy")) then
				local enemy = self.occupationMap:at(tilePosition)

				if (self.position.x < enemy.position.x) then
					enemy:die(32)
				else
					enemy:die(-32)
				end
			end

			break
		end
	end

	Scheduler:waitForFlux(main)

	local i = love.math.random(1, #MoveSounds)
	MoveSounds[i]:setPitch(love.math.random(95, 105)/100)
	MoveSounds[i]:play()

	self.rotation = rotation

	self:updateMovementIndicators()
	self.occupationMap:update(self, Utils:vWorldToTile(self.position))
end

function Player:moveTo(targetPosition, rotation, time)
	return Scheduler:enqueue(moveTo, self, targetPosition, rotation, time)
end

local function die(self, offset)
	dieSound:setPitch(love.math.random(95, 105)/100)
	dieSound:play()

	local startPosition = self.position:copy()
	Flux.to(self, 1, {rotation = -math.pi/4}):ease("quadout")
	Scheduler:waitForFlux(Flux.to(self.position, 0.3, {x = startPosition.x + offset}):ease("linear"))

	transition("DEAD")
end

function Player:die(offset)
	return Scheduler:waitFor(die, self, offset)
end

function Player:keypressed(key)
	if (self.turnsLeft > 0 and not self.moving) then
		local dx, dy = 0, 0

		if (love.keyboard.isDown("w") or love.keyboard.isDown("up")) then
			dy = 32
		end

		if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) then
			dx = -32
		end

		if (love.keyboard.isDown("s") or love.keyboard.isDown("down")) then
			dy = -32
		end

		if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) then
			dx = 32
		end

		if (dx ~= 0 or dy ~= 0) then
			local targetPosition = Vec3(self.position.x + dx, self.position.y + dy, self.position.z)
			local tilePosition = Utils:vWorldToTile(targetPosition)

			if (not self.occupationMap:atOfType(tilePosition, "isWall")) then
				Scheduler:enqueue(function()
					self.moving = true

					local move = self:moveTo(targetPosition, 0, 0.35)
					while (not move.done) do coroutine.yield() end

					self.moving = false
					self.turnsLeft = self.turnsLeft - 1

					self:showResultDice(self.turnsLeft)
				end)
			end
		end
	end
end

return Player