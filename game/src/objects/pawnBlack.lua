local Chess = SheetLoader:loadSheet("assets/chess.png", require("assets.chess"))

local Enemy = require("src.objects.enemy")
local StandingSprite = require("src.objects.standingSprite")
local AttackIndicator = require("src.objects.attackIndicator")

local PawnBlack = Class("PawnBlack", Enemy)

function PawnBlack:initialize(position, occupationMap)
	Enemy.initialize(self)

	self.position = position
	self.rotation = 0
	self.sprite = StandingSprite(Chess.image, Chess.quads.pawn_black, position, 0)
	self.occupationMap = occupationMap
	self.occupationMap:add(self, Utils:vWorldToTile(self.position))

	self.indicators = {
		downLeft = AttackIndicator(self.position),
		downRight = AttackIndicator(self.position),
	}

	self:updateAttackIndicators()
end

function PawnBlack:updateAttackIndicators()
	self.indicators.downLeft.position = self.position:sadd(-32, -32, 0.01)
	self.indicators.downRight.position = self.position:sadd(32, -32, 0.01)
end

local function performTurn(self)
	local tilePosition = Utils:vWorldToTile(self.position)

	if (self.occupationMap:atOfType(tilePosition:sadd(-1, -1), "isPlayer")) then
		local move = self.position:sadd(-32, -32, 0)
		Scheduler:waitForP(self:moveTo(move, 0, 0.35))
	elseif (self.occupationMap:atOfType(tilePosition:sadd(1, -1), "isPlayer")) then
		local move = self.position:sadd(32, -32, 0)
		Scheduler:waitForP(self:moveTo(move, 0, 0.35))
	elseif (self.occupationMap:at(tilePosition:sadd(0, -1))) then

	else
		local move = self.position:sadd(0, -32, 0)
		Scheduler:waitForP(self:moveTo(move, 0, 0.35))
	end

	self:updateAttackIndicators()
end

function PawnBlack:performTurn()
	return Scheduler:enqueue(performTurn, self)
end

function PawnBlack:update(dt)
	self.occupationMap:update(self, Utils:vWorldToTile(self.position))
end

function PawnBlack:draw()
	if (not self.isMoving) then
		self.indicators.downLeft:draw()
		self.indicators.downRight:draw()
	end

	self.sprite:setPosition(self.position)
	self.sprite:setRotation(self.rotation)

	self.sprite:draw()
end

return PawnBlack