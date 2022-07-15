return function(e, image, json, tag, position, pivot, flipX, flipY)
	e
	:give("transform", position, 0)
	:give("animatedSprite", image, json, tag)
	e
	:give("sprite",
		e.animatedSprite.animatedImage.image,
		e.animatedSprite.animatedImage.frame.quad,
		pivot, nil, flipX, flipY
	)

	return e
end