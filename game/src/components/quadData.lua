local QuadData = ECS.component("quadData", function(e)
	e.topLeft = {position = Vec3(), uvs = Vec2()}
	e.topRight = {position = Vec3(), uvs = Vec2()}
	e.bottomLeft = {position = Vec3(), uvs = Vec2()}
	e.bottomRight = {position = Vec3(), uvs = Vec2()}

	e.normal = Vec3()
end)

function QuadData:updateNormal(p1, p2, p3)
	local q = p1:vsub(p2)
	local r = p3:vsub(p2)
	Vec3.cross(q, r, self.normal):normalisei()
end

local cross = Vec3()
function QuadData:rotatePoint(p, position, pivot, rotation, origin)
	if (rotation ~= 0) then
		local c = math.cos(rotation)
		local s = math.sin(rotation)

		p:vsubi(position):vsubi(pivot)
		Vec3.cross(self.normal, p, cross):smuli(s)
		p:smuli(c):vaddi(cross)
		p:vaddi(position):vaddi(pivot)
	end

	p:vsubi(origin)

	return p
end