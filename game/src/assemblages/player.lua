return function(e, image, quad, position, pivot, gun)
	return e
	:assemble(Assemblages.prop, image, quad, position, pivot)
	:give("controls")
	:give("velocity", Vec3(0, 0, 0))
	:give("attachment", gun, Vec3(-4, -3))
end