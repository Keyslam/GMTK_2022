local MovementIndicatorSheet = SheetLoader:loadSheet("assets/crosshairs.png", require("assets.crosshairs"))

local Entity = require("src.objects.entity")
local FlatSprite = require("src.objects.flatSprite")

local MovementIndicator = Class("MovementIndicator", Entity)

function MovementIndicator:initialize(position)
	self.position = position
	self.sprite = FlatSprite(MovementIndicatorSheet.image, MovementIndicatorSheet.quads.tile_1x1_valid, position, 0)
end

function MovementIndicator:draw()
	self.sprite:setPosition(self.position)
	self.sprite:draw()
end

return MovementIndicator