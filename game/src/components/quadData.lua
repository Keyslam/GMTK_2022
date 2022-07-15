local QuadData = ECS.component("quadData", function(e)
	e.topLeft     = { localPosition = Vec3(), worldPosition = Vec3(), uvs = Vec2() }
	e.topRight    = { localPosition = Vec3(), worldPosition = Vec3(), uvs = Vec2() }
	e.bottomLeft  = { localPosition = Vec3(), worldPosition = Vec3(), uvs = Vec2() }
	e.bottomRight = { localPosition = Vec3(), worldPosition = Vec3(), uvs = Vec2() }
end)

function QuadData:buildLocalData(sprite)
	local ix, iy, iw, ih = sprite.qx, sprite.qy, sprite.qw, sprite.qh
	local sw, sh = sprite.sw, sprite.sh

	local u1 = ix / sw
	local u2 = u1 + iw / sw
	local v1 = iy / sh
	local v2 = v1 + ih / sh

	self.topLeft.uvs:sset(u2, v2)
	self.topRight.uvs:sset(u1, v2)
	self.bottomLeft.uvs:sset(u2, v1)
	self.bottomRight.uvs:sset(u1, v1)

	local x1, x2 = -iw/2, iw/2
	local y1, y2 = -ih/2, ih/2
	local z1, z2 = 0, 0

	self.topLeft.localPosition:sset(x2, y1, z1)
	self.topRight.localPosition:sset(x1, y1, z1)
	self.bottomLeft.localPosition:sset(x2, y2, z2)
	self.bottomRight.localPosition:sset(x1, y2, z2)
end

function QuadData:localPointToFlatPoint(p, transform, sprite)
	p:vector_sub_inplace(sprite.pivot)
	p:rotate_inplace(transform.rotation)
end

local tempP3 = Vec3(0, 0, 0)
function QuadData:flatPointTo3DPoint(p, transform, sprite)
	local height = sprite.height
	local qh = sprite.qh

	local z = height * (p.y / qh)

	return tempP3:sset(p.x, p.y, z):vaddi(transform.position)
end

local tempP = Vec2(0, 0)
function QuadData:localPointTo3DPoint(p, transform, sprite)
	tempP:vset(p)

	self:localPointToFlatPoint(tempP, transform, sprite)
	return self:flatPointTo3DPoint(tempP, transform, sprite)
end

function QuadData:updateWorldPositions(transform, sprite)
	self.topLeft.worldPosition:vset(self:localPointTo3DPoint(self.topLeft.localPosition, transform, sprite))
	self.topRight.worldPosition:vset(self:localPointTo3DPoint(self.topRight.localPosition, transform, sprite))
	self.bottomLeft.worldPosition:vset(self:localPointTo3DPoint(self.bottomLeft.localPosition, transform, sprite))
	self.bottomRight.worldPosition:vset(self:localPointTo3DPoint(self.bottomRight.localPosition, transform, sprite))
end