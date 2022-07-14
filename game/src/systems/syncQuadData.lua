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

		local x1 = position.x
		local x2 = x1 + iw
		local y1 = position.y + position.z
		local y2 = y1 + ih
		local z1 = position.z
		local z2 = position.z

		if (e.sprite.flipX) then
			u1, u2 = u2, u1
		end

		if (e.sprite.kind == "STANDING") then
			z2 = z2 + ih
			pivot.y = pivot.y + position.z
		end

		p1:sset(x2, y1, z1)
		p2:sset(x1, y1, z1)
		p3:sset(x2, y2, z2)
		p4:sset(x1, y2, z2)

		if (rotation ~= 0) then
			p1:vsubi(position):vsubi(pivot)
			p2:vsubi(position):vsubi(pivot)
			p3:vsubi(position):vsubi(pivot)
			p4:vsubi(position):vsubi(pivot)

			local q = p1:vsub(p2)
			local r = p3:vsub(p2)
			Vec3.cross(q, r, normal):normalisei()

			local c = math.cos(rotation)
			local s = math.sin(rotation)

			Vec3.cross(normal, p1, p1c):smuli(s)
			Vec3.cross(normal, p2, p2c):smuli(s)
			Vec3.cross(normal, p3, p3c):smuli(s)
			Vec3.cross(normal, p4, p4c):smuli(s)

			p1:smuli(c):vaddi(p1c)
			p2:smuli(c):vaddi(p2c)
			p3:smuli(c):vaddi(p3c)
			p4:smuli(c):vaddi(p4c)

			p1:vaddi(position):vaddi(pivot)
			p2:vaddi(position):vaddi(pivot)
			p3:vaddi(position):vaddi(pivot)
			p4:vaddi(position):vaddi(pivot)
		end

		p1:vsubi(origin)
		p2:vsubi(origin)
		p3:vsubi(origin)
		p4:vsubi(origin)

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
