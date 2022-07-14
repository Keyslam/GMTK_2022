return function(e, image, quad, position, origin, pivot)
	return e
	:assemble(Assemblages.prop, image, quad, position, origin, pivot)
	:give("controls")
	:give("velocity", Vec3(0, 0, 0))
end