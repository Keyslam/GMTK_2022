local IkSolving = ECS.system({
	pool = {"ik"}
})

function IkSolving:update(dt)
	for _, e in ipairs(self.pool) do
		local root = e.ik.root
		local hip = e.ik.hip
		local knee = e.ik.knee

		local rootConnection = Vec3():vset(e.ik.rootConnection)
		do
			local pivot = Vec3():vset(root.sprite.pivotFlat)
			local normal = Vec3():vset(root.quadData.flatNormal)
			rootConnection = hip.quadData:localToWorldNoZ(rootConnection, root.transform.position, pivot, root.transform.rotation, normal)
		end

		hip.transform.position:vset(rootConnection)
		hip.transform.rotation = math.cos(love.timer.getTime()) * 0.8

		-- local hipConnection = Vec3():vset(e.ik.hipConnection)
		-- do
		-- 	local pivotFlat = Vec3():vset(hip.sprite.pivotFlat)
		-- 	local normalFlat = Vec3():vset(hip.quadData.flatNormal)
		-- 	local flatHipConnection = Vec3():vset(hip.quadData:localToWorldNoZ(hipConnection, hip.transform.position, pivotFlat, hip.transform.rotation, normalFlat))

		-- 	local pivotDiagonal = Vec3():vset(hip.sprite.pivotDiagonal)
		-- 	local normalDiagonal = Vec3():vset(hip.quadData.diagonalNormal)
		-- 	local diagonalHipConnection = Vec3():vset(hip.quadData:localToWorldNoZ(hipConnection, hip.transform.position, pivotDiagonal, hip.transform.rotation, normalDiagonal))

		-- 	hipConnection:sset(flatHipConnection.x, flatHipConnection.y, diagonalHipConnection.z)
		-- end
		-- knee.transform.position:vset(hipConnection)
		-- knee.transform.rotation = math.sin(love.timer.getTime() * 1.7) * 0.8

		-- -- local hipConnection = Vec3():vset(e.ik.hipConnection)
		-- -- hip.quadData:rotatePoint(hipConnection, hip.transform.position, hip.sprite.pivot, hip.transform.rotation, hip.sprite.origin)
		-- -- -- local hip2d = Vec2(e.ik.hipConnection.x, e.ik.hipConnection.y)
		-- -- -- hip2d:rotate_around_inplace(hip.transform.rotation, hip.transform.position)
		-- -- -- local hip3d = Vec3(hip2d.x, hip2d.y, 0)
		-- local hipConnection = Vec3():vset(e.ik.hipConnection)
		-- do
		-- 	hip.quadData:localToWorld(hipConnection, hip.transform.position, hip.sprite.pivot, hip.transform.rotation)
		-- 	print(hipConnection)
		-- 	-- local ix, iy, iw, ih = root.sprite.quad:getViewport()
		-- 	-- hipConnection.z = hipConnection.z + (hipConnection.y/(ih/2) * ih/2)
		-- end

		-- knee.transform.position:vset(hipConnection)
		-- knee.transform.rotation = math.sin(love.timer.getTime() * 1.7) * 0.8
	end
end

return IkSolving