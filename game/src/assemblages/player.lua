return function(e, image, quad, position, pivot)
	return e
	:assemble(Assemblages.prop, image, quad, position, pivot)
	:give("controls")
	:give("velocity", Vec3(0, 0, 0))
end