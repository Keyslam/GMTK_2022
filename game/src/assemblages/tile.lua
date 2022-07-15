return function(e, image, quad, position, pivot)
	return e
	:give("transform", position, 0)
	:give("sprite", image, quad, pivot, 0, false, false)
end