return function(e, image, quad, position, pivot, flipX, flipY)
	return e
	:give("transform", position, 0)
	:give("sprite", image, quad, pivot, nil, flipX, flipY)
end