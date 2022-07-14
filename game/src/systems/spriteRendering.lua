local TDRenderer = require("src.tdrenderer")

local SpriteRendering = ECS.system({
	pool = { "sprite", "quadData" },
	animated = { "animatedSprite", "quadData" }
})

function SpriteRendering:draw()
	for _, e in ipairs(self.pool) do
		TDRenderer:queueQuadData(e.sprite.image, e.quadData)
	end

	for _, e in ipairs(self.animated) do

	end
end

return SpriteRendering
