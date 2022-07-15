return function(e, position, rotation, width, height, near, far, target)
	local halfWidth = width/2
	local halfHeight = height/2

	near = near or 0.1
	far = far or 1000

	return e
	:give("transform", position, 0)
	:give("tdRotation", rotation)
	:give("projection", CPML.mat4.from_ortho(
		-halfWidth, halfWidth,
		-halfHeight, halfHeight,
		near, far
	))
	:give("cameraFollowing", target)
	-- :give("projection", CPML.mat4.from_perspective(
	-- 	90, 
	-- 	love.graphics.getWidth() / love.graphics.getHeight(), 
	-- 	0.1, 
	-- 	1000
	-- ))
end