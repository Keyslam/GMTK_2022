local Chess = SheetLoader:loadSheet("assets/chess.png", require("assets.chess"))

local Enemy = require("src.objects.enemy")
local StandingSprite = require("src.objects.standingSprite")
local AttackIndicator = require("src.objects.attackIndicator")

local PawnWhite = Class("PawnWhite", Enemy)

function PawnWhite:initialize(position, occupationMap)
	Enemy.initialize(self)

	self.position = position
	self.rotation = 0
	self.sprite = StandingSprite(Chess.image, Chess.quads.pawn_white, position, 0)
	self.occupationMap = occupationMap
	self.occupationMap:add(self, Utils:vWorldToTile(self.position))

	self.indicators = {
		upLeft = AttackIndicator(self.position),
		upRight = AttackIndicator(self.position),
	}

	self:updateAttackIndicators()
end

function PawnWhite:updateAttackIndicators()
	self.indicators.upLeft.position = self.position:sadd(-32, 32, 0.01)
	self.indicators.upRight.position = self.position:sadd(32, 32, 0.01)
end

local function performTurn(self)
	local tilePosition = Utils:vWorldToTile(self.position)

	if (self.occupationMap:atOfType(tilePosition:sadd(-1, 1), "isPlayer")) then
		local move = self.position:sadd(-32, 32, 0)
		Scheduler:waitForP(self:moveTo(move, 0, 0.15))
	elseif (self.occupationMap:atOfType(tilePosition:sadd(1, 1), "isPlayer")) then
		local move = self.position:sadd(32, 32, 0)
		Scheduler:waitForP(self:moveTo(move, 0, 0.15))
	elseif (self.occupationMap:at(tilePosition:sadd(0, 1))) then

	else
		local move = self.position:sadd(0, 32, 0)
		Scheduler:waitForP(self:moveTo(move, 0, 0.1))
	end

	self:updateAttackIndicators()
	self.occupationMap:update(self, Utils:vWorldToTile(self.position))
end

function PawnWhite:die(offset)
	self.occupationMap:remove(self)
	return Enemy.die(self, offset)
end

function PawnWhite:update(dt)
end

function PawnWhite:performTurn()
	return Scheduler:enqueue(performTurn, self)
end

function PawnWhite:draw()
	if (not self.isMoving) then
		self.indicators.upLeft:draw()
		self.indicators.upRight:draw()
	end

	self.sprite:setPosition(self.position)
	self.sprite:setRotation(self.rotation)

	self.sprite:draw()
end

return PawnWhite