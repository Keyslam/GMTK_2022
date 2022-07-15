local TDRenderer = require("src.tdrenderer")

local SpriteRendering = ECS.system({
	pool = { "sprite", "quadData" },
})

function SpriteRendering:draw()
	for _, e in ipairs(self.pool) do
		TDRenderer:queueQuadData(e.sprite.image, e.quadData)
	end
end

return SpriteRendering
