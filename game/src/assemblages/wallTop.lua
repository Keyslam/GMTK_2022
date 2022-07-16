return function(e, image, quad, position)
	return e
	:assemble(Assemblages.tile, image, quad, position, Vec2(0, 0))
	:give("mapOccupation", {Vec2(0, 0), Vec2(0, 1)})
end