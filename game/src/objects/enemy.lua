local Entity = require("src.objects.entity")
local StandingSprite = require("src.objects.standingSprite")

local MoveSounds = {
	love.audio.newSource("assets/sfx/move1-bounce-4.wav", "stream"),
	love.audio.newSource("assets/sfx/move2-bounce-4.wav", "stream"),
}


local dieSound = love.audio.newSource("assets/sfx/metal_hit-bounce-1.wav", "static")

local Enemy = Class("Enemy", Entity)

function Enemy:initialize()
	self.isEnemy = true
	self.isMoving = false
end

local function moveTo(self, targetPosition, rotation, time)
	self.isMoving = true
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
			if (self.occupationMap:atOfType(tilePosition, "isPlayer")) then
				local player = self.occupationMap:at(tilePosition)

				if (self.position.x < player.position.x) then
					player:die(32)
				else
					player:die(-32)
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
	self.isMoving = false
end

function Enemy:moveTo(targetPosition, rotation, time)
	return Scheduler:enqueue(moveTo, self, targetPosition, rotation, time)
end

local function performTurn(self)
end

local function die(self, offset)
	self.isMoving = true

	dieSound:setPitch(love.math.random(95, 105)/100)
	dieSound:play()

	local startPosition = self.position:copy()
	local rotation = offset > 0 and -math.pi/4 or math.pi/2
	Flux.to(self, 1, {rotation = rotation}):ease("quadout")
	Scheduler:waitForFlux(Flux.to(self.position, 0.3, {x = startPosition.x + offset}):ease("linear"))

	self.dead = true
end

function Enemy:die(offset)
	return Scheduler:waitFor(die, self, offset)
end

function Enemy:performTurn()
	return Scheduler:enqueue(performTurn, self)
end

function Enemy:draw()
end

return Enemy