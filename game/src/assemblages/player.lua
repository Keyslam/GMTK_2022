return function(e, image, quad, position)
	return e
	:assemble(Assemblages.prop, image, quad, position)
	:give("controls")
	:give("velocity", CPML.vec3(0, 0, 0))
end