local AnimatedSprite = ECS.component("animatedSprite", function(e, image, json, tag)
	e.animatedImage = Peachy.new(json, image, tag)
	e.tag = tag
end)