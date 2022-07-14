local AnimatedSprite = ECS.component("animatedSprite", function(e, image, json, tag, kind, flipX, flipY)
	e.animatedImage = Peachy.new(json, image, tag)
	e.tag = tag
	e.kind = kind
	e.flipX = flipX
	e.flipY = flipY
end)