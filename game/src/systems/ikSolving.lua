local IkSolving = ECS.system({
	pool = {"ik"}
})

function IkSolving:update(dt)
	for _, e in ipairs(self.pool) do
		local root = e.ik.root
		local hip = e.ik.hip
		local knee = e.ik.knee

		hip.transform.position:vset(root.transform.position):vsubi(e.ik.rootConnection)
		hip.transform.rotation = math.cos(love.timer.getTime()) * 2

		local hipConnection = Vec3():vset(e.ik.hipConnection)
		hip.quadData:rotatePoint(hipConnection, hip.transform.position, hip.sprite.pivot, hip.transform.rotation, hip.sprite.origin)
		-- local hip2d = Vec2(e.ik.hipConnection.x, e.ik.hipConnection.y)
		-- hip2d:rotate_around_inplace(hip.transform.rotation, hip.transform.position)
		-- local hip3d = Vec3(hip2d.x, hip2d.y, 0)

		knee.transform.position:vset(hip.transform.position):vsubi(hipConnection)
		knee.transform.rotation = math.sin(love.timer.getTime() * 1.7) * 0.2
	end
end

return IkSolving