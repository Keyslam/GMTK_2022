return function(e, image, quad, position)
	return e
	:give("transform", position, 0)
	:give("sprite", image, quad, Vec2(0, 0), 0, false, false)
	:give("dynamic")
end