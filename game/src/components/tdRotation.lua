local TDRotation = ECS.component("tdRotation", function(e, rotation)
	e.rotation = rotation

	e.right = nil
	e.up = nil
	e.forward = nil
	e.direction = nil
end)

function TDRotation:updateAxis()
	self.direction = Vec3(
		math.cos(self.rotation.y) * math.sin(self.rotation.x),
		math.sin(self.rotation.y),
		math.cos(self.rotation.y) * math.cos(self.rotation.x)
	)

	self.right = Vec3(
		math.sin(self.rotation.x - math.pi / 2),
		0,
		math.cos(self.rotation.x - math.pi / 2)
	)

	self.forward = Vec3(
		math.sin(self.rotation.x + math.pi),
		0,
		math.cos(self.rotation.x + math.pi)
	)

	self.up = Vec3.cross(self.right, self.direction)
end
