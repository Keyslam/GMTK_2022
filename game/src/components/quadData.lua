local QuadData = ECS.component("quadData", function(e)
	e.topLeft     = { localFlatPosition = Vec3(), localDiagonalPosition = Vec3(), worldPosition = Vec3(), uvs = Vec2() }
	e.topRight    = { localFlatPosition = Vec3(), localDiagonalPosition = Vec3(), worldPosition = Vec3(), uvs = Vec2() }
	e.bottomLeft  = { localFlatPosition = Vec3(), localDiagonalPosition = Vec3(), worldPosition = Vec3(), uvs = Vec2() }
	e.bottomRight = { localFlatPosition = Vec3(), localDiagonalPosition = Vec3(), worldPosition = Vec3(), uvs = Vec2() }

	e.flatNormal = Vec3()
	e.diagonalNormal = Vec3()
end)

function QuadData:buildLocalData(sprite)
	local quad = sprite.quad

	local ix, iy, iw, ih = quad:getViewport()
	local sw, sh = quad:getTextureDimensions()

	do -- UVs
		local u1 = ix / sw
		local u2 = u1 + iw / sw
		local v1 = iy / sh
		local v2 = v1 + ih / sh

		self.topLeft.uvs:sset(u2, v2)
		self.topRight.uvs:sset(u1, v2)
		self.bottomLeft.uvs:sset(u2, v1)
		self.bottomRight.uvs:sset(u1, v1)
	end

	local x1, x2 = -iw/2, iw/2
	local y1, y2 = -ih/2, ih/2
	local z1, z2 = 0, 0

	do -- Local flat positions
		self.topLeft.localFlatPosition:sset(x2, y1, z1)
		self.topRight.localFlatPosition:sset(x1, y1, z1)
		self.bottomLeft.localFlatPosition:sset(x2, y2, z2)
		self.bottomRight.localFlatPosition:sset(x1, y2, z2)
	end

	do -- Local diagonal positions
		z1 = -ih/2
		z2 = ih/2

		self.topLeft.localDiagonalPosition:sset(x2, y1, z1)
		self.topRight.localDiagonalPosition:sset(x1, y1, z1)
		self.bottomLeft.localDiagonalPosition:sset(x2, y2, z2)
		self.bottomRight.localDiagonalPosition:sset(x1, y2, z2)
	end

	self:updateNormals()
end

function QuadData:updateNormals()
	do
		local p1 = self.topLeft.localFlatPosition
		local p2 = self.topRight.localFlatPosition
		local p3 = self.bottomLeft.localFlatPosition

		local q = p1:vsub(p2)
		local r = p3:vsub(p2)
		Vec3.cross(q, r, self.flatNormal):normalisei()
	end

	do
		local p1 = self.topLeft.localDiagonalPosition
		local p2 = self.topRight.localDiagonalPosition
		local p3 = self.bottomLeft.localDiagonalPosition

		local q = p1:vsub(p2)
		local r = p3:vsub(p2)
		Vec3.cross(q, r, self.diagonalNormal):normalisei()
	end
end

local p = Vec3()
local cross = Vec3()
function QuadData:localToWorld(_p, position, pivot, rotation, normal)
	p:vset(_p)

	-- Translate point so the pivot is at 0, 0
	p:vsubi(pivot)

	if (rotation ~= 0) then
		local c = math.cos(rotation)
		local s = math.sin(rotation)

		-- Rotation based on https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula
		-- Reduced to just the parralel part, since points are always parralel to the rotation axis
		Vec3.cross(normal, p, cross):smuli(s)
		p:smuli(c):vaddi(cross)
	end

	-- Translate to world position
	p:vaddi(position)
	p:saddi(0, position.z, 0)

	return p
end

function QuadData:localToWorldNoZ(_p, position, pivot, rotation, normal)
	p:vset(_p)

	-- Translate point so the pivot is at 0, 0
	p:vsubi(pivot)

	if (rotation ~= 0) then
		local c = math.cos(rotation)
		local s = math.sin(rotation)

		-- Rotation based on https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula
		-- Reduced to just the parralel part, since points are always parralel to the rotation axis
		Vec3.cross(normal, p, cross):smuli(s)
		p:smuli(c):vaddi(cross)
	end

	-- Translate to world position
	p:vaddi(position)

	return p
end

function QuadData:updateWorldPositionsFromFlat(transform, sprite)
	local position = transform.position
	local rotation = transform.rotation
	local pivot = sprite.pivotFlat
	local normal = self.flatNormal

	self.topLeft.worldPosition:vset(self:localToWorld(self.topLeft.localFlatPosition, position, pivot, rotation, normal))
	self.topRight.worldPosition:vset(self:localToWorld(self.topRight.localFlatPosition, position, pivot, rotation, normal))
	self.bottomLeft.worldPosition:vset(self:localToWorld(self.bottomLeft.localFlatPosition, position, pivot, rotation, normal))
	self.bottomRight.worldPosition:vset(self:localToWorld(self.bottomRight.localFlatPosition, position, pivot, rotation, normal))
end

function QuadData:updateWorldPositionsFromDiagonal(transform, sprite)
	local position = transform.position
	local rotation = transform.rotation
	local pivot = sprite.pivotDiagonal
	local normal = self.diagonalNormal

	self.topLeft.worldPosition:vset(self:localToWorld(self.topLeft.localDiagonalPosition, position, pivot, rotation, normal))
	self.topRight.worldPosition:vset(self:localToWorld(self.topRight.localDiagonalPosition, position, pivot, rotation, normal))
	self.bottomLeft.worldPosition:vset(self:localToWorld(self.bottomLeft.localDiagonalPosition, position, pivot, rotation, normal))
	self.bottomRight.worldPosition:vset(self:localToWorld(self.bottomRight.localDiagonalPosition, position, pivot, rotation, normal))
end