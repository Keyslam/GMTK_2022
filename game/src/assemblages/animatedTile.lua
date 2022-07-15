return function(e, image, json, tag, position, pivot, flipX, flipY)
	e
	:give("transform", position, 0)
	:give("animatedSprite", image, json, tag, pivot, 0, flipX, flipY)
	e
	:give("sprite",
		e.animatedSprite.animatedImage.image,
		e.animatedSprite.animatedImage.frame.quad,
		pivot, 0, flipX, flipY
	)

	return e
end