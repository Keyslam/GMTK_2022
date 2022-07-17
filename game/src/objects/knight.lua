local Chess = SheetLoader:loadSheet("assets/chess.png", require("assets.chess"))

local Enemy = require("src.objects.enemy")
local StandingSprite = require("src.objects.standingSprite")
local AttackIndicator = require("src.objects.attackIndicator")

local Knight = Class("Knight", Enemy)

local movement = {
	{x =  1, y =  2},
	{x =  2, y =  1},
	{x =  2, y = -1},
	{x =  1, y = -2},
	{x = -1, y = -2},
	{x = -2, y = -1},
	{x = -2, y =  1},
	{x = -1, y =  2},
}

function Knight:initialize(position, occupationMap, isWhite)
	Enemy.initialize(self)

	self.position = position
	self.rotation = 0
	self.sprite = StandingSprite(Chess.image, isWhite and Chess.quads.knight_white or Chess.quads.knight_black, position, 0)
	self.occupationMap = occupationMap
	self.occupationMap:add(self, Utils:vWorldToTile(self.position))

	self.indicators = {}

	for _, mov in ipairs(movement) do
		table.insert(self.indicators, AttackIndicator(self.position))
	end

	self:updateAttackIndicators()
end

function Knight:updateAttackIndicators()
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
		Scheduler:waitForP(self:moveTo(Utils:vTileToWorld(targetPos), 0, 0.15))
	end

	self:updateAttackIndicators()
	self.occupationMap:update(self, Utils:vWorldToTile(self.position))
end

function Knight:die(offset)
	self.occupationMap:remove(self)
	return Enemy.die(self, offset)
end

function Knight:update(dt)
end

function Knight:performTurn()
	return Scheduler:enqueue(performTurn, self)
end

function Knight:draw()
	if (not self.isMoving) then
		for _, indiciator in ipairs(self.indicators) do
			indiciator:draw()
		end
	end

	self.sprite:setPosition(self.position)
	self.sprite:setRotation(self.rotation)

	self.sprite:draw()
end

return Knight