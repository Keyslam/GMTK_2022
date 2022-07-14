return function(e, image, quad, position)
	return e
	:give("transform", position, CPML.vec2(0, 0))
	:give("sprite", image, quad, "PROP", false, false)
end