local TDRenderer = require("src.tdrenderer")
local QuadData = require("src.objects.quadData")

local StandingSprite = Class("StandingSprite")

function StandingSprite:initialize(image, quad, position, rotation)
	local _, _ , _, h = quad:getViewport()

	self.image = image
	self.quadData = QuadData(quad, position, rotation, Vec2(0, -h/2), h)

	self.worldPositionsDirty = true
end

function StandingSprite:setQuad(quad)
	self.quadData.quad = quad
	self.quadData:updateUvs()
	self.quadData:updateLocalPositions()
end

function StandingSprite:setPosition(position)
	self.quadData.position = position
	self.worldPositionsDirty = true
end

function StandingSprite:setRotation(rotation)
	self.quadData.rotation = rotation
	self.worldPositionsDirty = true
end

function StandingSprite:draw()
	if (self.worldPositionsDirty) then
		self.quadData:updateWorldPositions()
		self.worldPositionsDirty = false
	end

	TDRenderer:queueQuadData(self.image, self.quadData)
end

return StandingSprite