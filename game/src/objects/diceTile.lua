local Entity = require("src.objects.entity")
local FlatSprite = require("src.objects.flatSprite")

local DiceTile = Class("DiceTile", Entity)

function DiceTile:initialize(position, image, quad, inactiveQuad, index)
	self.quad = quad
	self.inactiveQuad = inactiveQuad
	self.index = index
	self.sprite = FlatSprite(image, quad, position, 0)
end

function DiceTile:draw()
	if (dicetile == self.index) then
		self.sprite:setQuad(self.quad)
	else
		self.sprite:setQuad(self.inactiveQuad)
	end
	self.sprite:draw()
end

return DiceTile