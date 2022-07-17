local AttackIndicator = SheetLoader:loadSheet("assets/crosshairs.png", require("assets.crosshairs"))

local Entity = require("src.objects.entity")
local FlatSprite = require("src.objects.flatSprite")

local MovementIndicator = Class("MovementIndicator", Entity)

function MovementIndicator:initialize(position)
	self.position = position
	self.sprite = FlatSprite(AttackIndicator.image, AttackIndicator.quads.tile_1x1_invalid, position, 0)
end

function MovementIndicator:draw()
	self.sprite:setPosition(self.position)
	self.sprite:draw()
end

return MovementIndicator