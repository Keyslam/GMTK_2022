return function(e, image, quad, position, pivot)
	return e
	:assemble(Assemblages.prop, image, quad, position, pivot)
	:give("controls")
	:give("dynamic")
	:give("actions", 5, true)
	:give("mapOccupation", {Vec2(0, 0)})
end