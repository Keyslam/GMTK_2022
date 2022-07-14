local TDRenderer = require("src.tdrenderer")

local SpriteRendering = ECS.system({
	pool = { "sprite", "quadData" },
	animated = { "transform", "animatedSprite" }
})

function SpriteRendering:draw()
	for _, e in ipairs(self.pool) do
		TDRenderer:writeQuadData(e.sprite.image, e.quadData)
		-- if (e.sprite.kind == "TILE") then
		-- 	TDRenderer:drawFlat(
		-- 		e.sprite.image,
		-- 		e.sprite.quad,
		-- 		e.transform.position,
		-- 		e.transform.rotation,
		-- 		e.sprite.origin,
		-- 		e.sprite.pivot,
		-- 		e.sprite.flipX,
		-- 		e.sprite.flipY
		-- 	)
		-- elseif (e.sprite.kind == "PROP") then
		-- 	TDRenderer:drawStanding(
		-- 		e.sprite.image,
		-- 		e.sprite.quad,
		-- 		e.transform.position,
		-- 		e.transform.rotation,
		-- 		e.sprite.origin,
		-- 		e.sprite.pivot,
		-- 		e.sprite.flipX,
		-- 		e.sprite.flipY
		-- 	)
		-- end
	end

	for _, e in ipairs(self.animated) do
		if (e.animatedSprite.kind == "TILE") then
			TDRenderer:drawFlat(
				e.animatedSprite.animatedImage.image,
				e.animatedSprite.animatedImage.frame.quad,
				e.transform.position,
				e.transform.rotation,
				e.animatedSprite.pivot,
				e.animatedSprite.flipX,
				e.animatedSprite.flipY
			)
		elseif (e.animatedSprite.kind == "PROP") then
			TDRenderer:drawStanding(
				e.animatedSprite.animatedImage.image,
				e.animatedSprite.animatedImage.frame.quad,
				e.transform.position,
				e.transform.rotation,
				e.animatedSprite.pivot,
				e.animatedSprite.flipX,
				e.animatedSprite.flipY
			)
		end
	end
end

return SpriteRendering
