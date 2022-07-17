local Chess = SheetLoader:loadSheet("assets/chess.png", require("assets.chess"))

local Enemy = require("src.objects.enemy")
local StandingSprite = require("src.objects.standingSprite")
local AttackIndicator = require("src.objects.attackIndicator")

local Queen = Class("Queen", Enemy)

local movement = {
	{x =  1, y =  1},
	{x =  2, y =  2},
	{x =  3, y =  3},
	{x =  -1, y =  1},
	{x =  -2, y =  2},
	{x =  -3, y =  3},
	{x =  1, y =  -1},
	{x =  2, y =  -2},
	{x =  3, y =  -3},
	{x =  -1, y =  -1},
	{x =  -2, y =  -2},
	{x =  -3, y =  -3},
	{x =  1, y = 0},
	{x =  2, y = 0},
	{x =  3, y = 0},
	{x =  -1, y = 0},
	{x =  -2, y = 0},
	{x =  -3, y = 0},
	{x =  0, y = 1},
	{x =  0, y = 2},
	{x =  0, y = 3},
	{x =  0, y = -1},
	{x =  0, y = -2},
	{x =  0, y = -3},
}

function Queen:initialize(position, occupationMap, isWhite)
	Enemy.initialize(self)

	self.position = position
	self.rotation = 0
	self.sprite = StandingSprite(Chess.image, isWhite and Chess.quads.queen_white or Chess.quads.queen_black, position, 0)
	self.occupationMap = occupationMap
	self.occupationMap:add(self, Utils:vWorldToTile(self.position))

	self.indicators = {}

	for _, mov in ipairs(movement) do
		table.insert(self.indicators, AttackIndicator(self.position))
	end

	self:updateAttackIndicators()
end

function Queen:updateAttackIndicators()
	for i, mov in ipairs(movement) do
		local indiciator = self.indicators[i]
		indiciator.position = self.position:sadd(mov.x * 32, mov.y * 32, 0.01)
	end
end

local function performTurn(self)
	local tilePosition = Utils:vWorldToTile(self.position)

	local targetPos
	for _, mov in ipairs(movement) do
		local t = tilePosition:sadd(mov.x, mov.y)
		if (self.occupationMap:atOfType(t, "isPlayer")) then
			targetPos = t
			break
		end
	end

	if (not targetPos) then
		local valids = {}

		for _, mov in ipairs(movement) do
			local t = tilePosition:sadd(mov.x, mov.y)
			if (not self.occupationMap:at(t)) then
				table.insert(valids, t)
			end
		end

		if (#valids > 0) then
			local i = love.math.random(1, #valids)
			targetPos = valids[i]
		end
	end

	if (targetPos) then
		Scheduler:waitForP(self:moveTo(Utils:vTileToWorld(targetPos), 0, 0.35))
	end

	self:updateAttackIndicators()
	self.occupationMap:update(self, Utils:vWorldToTile(self.position))
end

function Queen:die(offset)
	self.occupationMap:remove(self)
	return Enemy.die(self, offset)
end

function Queen:update(dt)
end

function Queen:performTurn()
	return Scheduler:enqueue(performTurn, self)
end

function Queen:draw()
	if (not self.isMoving) then
		for _, indiciator in ipairs(self.indicators) do
			indiciator:draw()
		end
	end

	self.sprite:setPosition(self.position)
	self.sprite:setRotation(self.rotation)

	self.sprite:draw()
end

return Queen