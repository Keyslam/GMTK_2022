local TDRenderer = require("src.tdrenderer")

local SpriteRendering = ECS.system({
	pool = {"transform", "sprite"}
})

function SpriteRendering:draw()
	for _, e in ipairs(self.pool) do
		if (e.sprite.kind == "TILE") then
			TDRenderer:drawFlat(e.sprite.image, e.sprite.quad, e.transform.position, e.sprite.flipX, e.sprite.flipY)
		elseif (e.sprite.kind == "PROP") then
			TDRenderer:drawStanding(e.sprite.image, e.sprite.quad, e.transform.position, e.sprite.flipX, e.sprite.flipY)
		end
	end
end

return SpriteRendering