local Entity = require("src.objects.entity")
local FlatSprite = require("src.objects.flatSprite")

local Floor = Class("Floor", Entity)

function Floor:initialize(position, image, quad)
	self.sprite = FlatSprite(image, quad, position, 0)
end

function Floor:draw()
	self.sprite:draw()
end

return Floor