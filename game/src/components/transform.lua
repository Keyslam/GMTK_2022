local Transform = ECS.component("transform", function(e, position, rotation)
	e.position = position
	e.rotation = rotation

	e.right = nil
	e.up = nil
	e.forward = nil
	e.direction = nil
end)