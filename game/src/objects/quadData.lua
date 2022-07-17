local QuadData = Class("QuadData")

function QuadData:initialize(quad, position, rotation, pivot, height)
	self.quad = quad
	self.position = position
	self.rotation = rotation
	self.pivot = pivot
	self.height = height

	self.topLeft     = { localPosition = Vec3(), worldPosition = Vec3(), uvs = Vec2() }
	self.topRight    = { localPosition = Vec3(), worldPosition = Vec3(), uvs = Vec2() }
	self.bottomLeft  = { localPosition = Vec3(), worldPosition = Vec3(), uvs = Vec2() }
	self.bottomRight = { localPosition = Vec3(), worldPosition = Vec3(), uvs = Vec2() }

	self:buildLocalData()
end

function QuadData:buildLocalData()
	self:updateUvs()
	self:updateLocalPositions()
end

function QuadData:updateUvs()
	local ix, iy, iw, ih = self.quad:getViewport()
	local sw, sh = self.quad:getTextureDimensions()

	local u1 = ix / sw
	local u2 = u1 + iw / sw
	local v1 = iy / sh
	local v2 = v1 + ih / sh

	self.topLeft.uvs:sset(u2, v2)
	self.topRight.uvs:sset(u1, v2)
	self.bottomLeft.uvs:sset(u2, v1)
	self.bottomRight.uvs:sset(u1, v1)
end

function QuadData:updateLocalPositions()
	local _, _, iw, ih = self.quad:getViewport()

	local x1, x2 = -iw/2, iw/2
	local y1, y2 = -ih/2, ih/2
	local z1, z2 = 0, 0

	self.topLeft.localPosition:sset(x2, y1, z1)
	self.topRight.localPosition:sset(x1, y1, z1)
	self.bottomLeft.localPosition:sset(x2, y2, z2)
	self.bottomRight.localPosition:sset(x1, y2, z2)
end

function QuadData:localPointToFlatPoint(p)
	p:vector_sub_inplace(self.pivot)
	p:rotate_inplace(self.rotation)
end

local tempP3 = Vec3(0, 0, 0)
function QuadData:flatPointTo3DPoint(p)
	local _, _, iw, ih = self.quad:getViewport()
	local height = self.height

	local z = height * (p.y / ih)

	return tempP3:sset(p.x, p.y, z):vaddi(self.position)
end

local tempP = Vec2(0, 0)
function QuadData:localPointTo3DPoint(p)
	tempP:vset(p)

	self:localPointToFlatPoint(tempP)
	return self:flatPointTo3DPoint(tempP)
end

function QuadData:localPointTo3DPointWithZ(p)
	return self:localPointTo3DPoint(p):saddi(0, self.position.z, 0)
end

function QuadData:updateWorldPositions()
	self.topLeft.worldPosition:vset(self:localPointTo3DPointWithZ(self.topLeft.localPosition))
	self.topRight.worldPosition:vset(self:localPointTo3DPointWithZ(self.topRight.localPosition))
	self.bottomLeft.worldPosition:vset(self:localPointTo3DPointWithZ(self.bottomLeft.localPosition))
	self.bottomRight.worldPosition:vset(self:localPointTo3DPointWithZ(self.bottomRight.localPosition))
end

return QuadData