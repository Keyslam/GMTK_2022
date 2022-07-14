return function(e, image, quad, tag, position)
	return e
	:give("transform", position, 0)
	:give("animatedSprite", image, quad, tag, "TILE", false, false)
end