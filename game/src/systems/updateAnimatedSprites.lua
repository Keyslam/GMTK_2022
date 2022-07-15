local UpdateAnimatedSprites = ECS.system({
	pool = {"animatedSprite", "sprite"}
})

function UpdateAnimatedSprites:update(dt)
	for _, e in ipairs(self.pool) do
		e.animatedSprite.animatedImage:update(dt)
		e.animatedSprite.animatedImage:setTag(e.animatedSprite.tag)
		e.sprite.quad = e.animatedSprite.animatedImage.frame.quad
	end
end

return UpdateAnimatedSprites