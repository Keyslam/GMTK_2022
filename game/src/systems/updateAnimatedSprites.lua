local TDRenderer = require("src.tdrenderer")

local UpdateAnimatedSprites = ECS.system({
	pool = {"animatedSprite"}
})

function UpdateAnimatedSprites:update(dt)
	for _, e in ipairs(self.pool) do
		e.animatedSprite.animatedImage:update(dt)
		e.animatedSprite.animatedImage:setTag(e.animatedSprite.tag)
	end
end

return UpdateAnimatedSprites