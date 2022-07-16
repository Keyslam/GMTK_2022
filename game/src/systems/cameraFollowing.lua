local CameraFollowing = ECS.system({
	pool = {"transform", "cameraFollowing"}
})

function CameraFollowing:update(dt)
	for _, e in ipairs(self.pool) do
		local position = e.transform.position
		local targetPosition = Vec3(0, 0, 0):vset(e.cameraFollowing.target.transform.position)
		targetPosition.x = math.floor(-targetPosition.x*3 + 0.5)/3
		targetPosition.y = math.floor(-targetPosition.y*3 + 0.5)/3
		targetPosition.z = position.z

		local newPosition = Vec3(0, 0, 0)
		local lerpSpeed = 1 - 0.002 ^ dt
		newPosition.x = Utils:lerp(position.x, targetPosition.x, lerpSpeed)
		newPosition.y = Utils:lerp(position.y, targetPosition.y, lerpSpeed)
		newPosition.z = targetPosition.z

		e.transform.position:vset(newPosition)
	end
end

return CameraFollowing