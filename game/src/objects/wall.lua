local Entity = require("src.objects.entity")
local FlatSprite = require("src.objects.flatSprite")
local StandingSprite = require("src.objects.standingSprite")

local Wall = Class("Wall", Entity)

function Wall:initialize(position, image, sideQuad, topQuad, occupationMap)
	self.position = position
	self.spriteSide = StandingSprite(image, sideQuad, position:ssub(0, 16, 0), 0)
	self.spriteTop = FlatSprite(image, topQuad, position:sadd(0, 0, 32), 0)
	self.occupationMap = occupationMap

	self.occupationMap:add(self, Utils:vWorldToTile(self.position))
	self.occupationMap:add(self, Utils:vWorldToTile(self.position):sadd(0, 1))

	self.isWall = true
end

function Wall:draw()
	self.spriteSide:draw()
	self.spriteTop:draw()
end

return Wall