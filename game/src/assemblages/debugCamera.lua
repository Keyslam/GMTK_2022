return function(e)
	local projection = CPML.mat4.from_perspective(
		90,
		love.graphics.getWidth() / love.graphics.getHeight(),
		0.1,
		1000
	)
	projection:scale(projection, CPML.vec3(-1, 1, 1))

	return e
	:give("transform", Vec3(0, 0, -200), 0)
	:give("tdRotation", Vec2(0, -math.pi))
	:give("projection", projection)
end