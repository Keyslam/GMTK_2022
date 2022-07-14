return function(e, position, rotation, width, height, near, far)
	local halfWidth = width/2
	local halfHeight = height/2

	near = near or 0.1
	far = far or 1000

	return e
	:give("transform", position, rotation)
	:give("projection", CPML.mat4.from_ortho(
		-halfWidth, halfWidth,
		-halfHeight, halfHeight,
		near, far
	))
end