local Transform = ECS.component("transform", function(e, position, rotation)
	e.position = position
	e.rotation = rotation

	e.right = nil
	e.up = nil
	e.forward = nil
	e.direction = nil
end)

function Transform:updateAxis()
	self.direction = CPML.vec3(
		math.cos(self.rotation.y) * math.sin(self.rotation.x),
		math.sin(self.rotation.y),
		math.cos(self.rotation.y) * math.cos(self.rotation.x)
	)

	self.right = CPML.vec3(
		math.sin(self.rotation.x - math.pi / 2),
		0,
		math.cos(self.rotation.x - math.pi / 2)
	)

	self.forward = CPML.vec3(
		math.sin(self.rotation.x + math.pi),
		0,
		math.cos(self.rotation.x + math.pi)
	)

	self.up = CPML.vec3.cross(self.right, self.direction)
end
