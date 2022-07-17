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

	Flux.to(self.position, time, {x = targetPosition.x, y = targetPosition.y}):ease("quadout")
	Scheduler:waitForFlux(Flux.to(self.position, time * 0.5, {z = startPosition.z + 15}):ease("quadout"))
	Scheduler:waitForFlux(Flux.to(self.position, time * 0.5, {z = startPosition.z}):ease("quadout"))

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

local function die(self)
	self.isMoving = true

	dieSound:setPitch(love.math.random(95, 105)/100)
	dieSound:play()

	local startPosition = self.position:copy()
	Flux.to(self, 1, {rotation = -math.pi/4}):ease("quadout")
	Scheduler:waitForFlux(Flux.to(self.position, 0.3, {x = startPosition.x + 32}):ease("linear"))

	self.dead = true
end

function Enemy:die()
	return Scheduler:waitFor(die, self)
end

function Enemy:performTurn()
	return Scheduler:enqueue(performTurn, self)
end

function Enemy:draw()
end

return Enemy