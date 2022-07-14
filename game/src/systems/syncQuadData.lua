local SyncQuadData = ECS.system({
	eligible = { "transform", "sprite"},
	pool = { "transform", "sprite", "quadData" }
})

function SyncQuadData:init()
	self.eligible.onAdded = function(_, e)
		e:give("quadData")
	end

	self.eligible.onRemoved = function(_, e)
		e:remove("quadData")
	end
end

function SyncQuadData:update(dt)
	local p1 = Vec3(0, 0, 0)
	local p2 = Vec3(0, 0, 0)
	local p3 = Vec3(0, 0, 0)
	local p4 = Vec3(0, 0, 0)
	local normal = Vec3()
	local p1c = Vec3()
	local p2c = Vec3()
	local p3c = Vec3()
	local p4c = Vec3()
	local pivot = Vec3()

	for _, e in ipairs(self.pool) do
		local quad = e.sprite.quad
		local position = e.transform.position
		local rotation = e.transform.rotation
		local origin = e.sprite.origin
		pivot:vset(e.sprite.pivot)

		local ix, iy, iw, ih = quad:getViewport()
		local sw, sh = quad:getTextureDimensions()

		local u1 = ix / sw
		local u2 = u1 + iw / sw
		local v1 = iy / sh
		local v2 = v1 + ih / sh

		if (e.sprite.flipX) then
			u1, u2 = u2, u1
		end

		local x1, x2 = position.x, position.x + iw
		local y1, y2 = position.y + position.z, position.y + position.z + ih
		local z1, z2 = position.z, position.z

		if (e.sprite.kind == "PROP") then
			z2 = z2 + ih
			pivot.y = pivot.y + position.z
		end

		p1:sset(x2, y1, z1)
		p2:sset(x1, y1, z1)
		p3:sset(x2, y2, z2)
		p4:sset(x1, y2, z2)

		e.quadData:updateNormal(p1, p2, p3)

		e.quadData:rotatePoint(p1, position, pivot, rotation, origin)
		e.quadData:rotatePoint(p2, position, pivot, rotation, origin)
		e.quadData:rotatePoint(p3, position, pivot, rotation, origin)
		e.quadData:rotatePoint(p4, position, pivot, rotation, origin)

		e.quadData.topLeft.position:vset(p1)
		e.quadData.topLeft.uvs:sset(u2, v2)

		e.quadData.topRight.position:vset(p2)
		e.quadData.topRight.uvs:sset(u1, v2)

		e.quadData.bottomLeft.position:vset(p3)
		e.quadData.bottomLeft.uvs:sset(u2, v1)

		e.quadData.bottomRight.position:vset(p4)
		e.quadData.bottomRight.uvs:sset(u1, v1)
	end
end

return SyncQuadData
