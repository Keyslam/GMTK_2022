local TDRenderer = require("src.tdrenderer")
local QuadData = require("src.objects.quadData")

local FlatSprite = Class("FlatSprite")

function FlatSprite:initialize(image, quad, position, rotation)
	self.image = image
	self.quadData = QuadData(quad, position, rotation, Vec2(0, 0), 0)

	self.worldPositionsDirty = true
end

function FlatSprite:setQuad(quad)
	self.quadData.quad = quad
	self.quadData:updateUvs()
	self.quadData:updateLocalPositions()
end

function FlatSprite:setPosition(position)
	self.quadData.position = position
	self.worldPositionsDirty = true
end

function FlatSprite:setRotation(rotation)
	self.quadData.rotation = rotation
	self.worldPositionsDirty = true
end

function FlatSprite:draw()
	if (self.worldPositionsDirty) then
		self.quadData:updateWorldPositions()
		self.worldPositionsDirty = false
	end

	TDRenderer:queueQuadData(self.image, self.quadData)
end

return FlatSprite