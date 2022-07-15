local CameraFollowing = ECS.system({
	pool = {"transform", "cameraFollowing"}
})

function CameraFollowing:update(dt)
	for _, e in ipairs(self.pool) do
		local position = e.transform.position
		local targetPosition = e.cameraFollowing.target.transform.position

		e.transform.position:sset(math.floor(-targetPosition.x*3 + 0.5)/3, math.floor(-targetPosition.y*3 + 0.5)/3, position.z)
	end
end

return CameraFollowing