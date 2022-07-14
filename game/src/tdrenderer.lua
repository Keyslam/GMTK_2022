local TDRenderer = {}

local VertexFormat = {
	{ "VertexPosition", "float", 3 },
	{ "VertexTexCoord", "float", 2 },
}
local TileSize = 16
local Shader = love.graphics.newShader("src/shaders/shader.glsl")
local ShadowShader = love.graphics.newShader("src/shaders/shadowShader.glsl")

local DepthBuffer = {
	color = love.graphics.newCanvas(1920, 1080, { format = "rgba8" }),
	depth = love.graphics.newCanvas(1920, 1080, { format = "depth24" }),
}
DepthBuffer.canvas = { DepthBuffer.color, depthstencil = DepthBuffer.depth }

local Shadowmap = {
	color = love.graphics.newCanvas(640, 360, { format = "rgba8" }),
	depth = love.graphics.newCanvas(640, 360, { format = "depth24", readable = true }),
}
Shadowmap.canvas = { Shadowmap.color, depthstencil = Shadowmap.depth }

local Queue = {}
local Meshes = {}

local shadowMesh = love.graphics.newMesh({
	{ 320, -180, 0, 1, 1, 1, 1, 1 },
	{ -320, -180, 1, 1, 1, 1, 1, 1 },
	{ 320, 180, 0, 0, 1, 1, 1, 1 },
	{ -320, 180, 1, 0, 1, 1, 1, 1 },
}, "triangles")
shadowMesh:setVertexMap({
	1, 3, 2, 2, 3, 4,
})
shadowMesh:setTexture(Shadowmap.depth)

function TDRenderer:drawFlat(image, quad, position, rotation, origin, pivot, flipX, flipY)
	rotation = rotation or 0
	if (flipX == nil) then flipX = false end
	if (flipY == nil) then flipY = false end

	if (not Queue[image]) then
		Queue[image] = {}
	end

	table.insert(Queue[image], quad)
	table.insert(Queue[image], position)
	table.insert(Queue[image], rotation)
	table.insert(Queue[image], origin)
	table.insert(Queue[image], pivot)
	table.insert(Queue[image], "FLAT")
	table.insert(Queue[image], flipX)
	table.insert(Queue[image], flipY)
end

function TDRenderer:drawStanding(image, quad, position, rotation, origin, pivot, flipX, flipY)
	rotation = rotation or 0
	if (flipX == nil) then flipX = false end
	if (flipY == nil) then flipY = false end

	if (not Queue[image]) then
		Queue[image] = {}
	end

	table.insert(Queue[image], quad)
	table.insert(Queue[image], position)
	table.insert(Queue[image], rotation)
	table.insert(Queue[image], origin)
	table.insert(Queue[image], pivot)
	table.insert(Queue[image], "STANDING")
	table.insert(Queue[image], flipX)
	table.insert(Queue[image], flipY)
end

function TDRenderer:drawCanvas()
	love.graphics.draw(DepthBuffer.color, 0, 0, 0, love.graphics.getWidth() / 1920, love.graphics.getHeight() / 1080)
end

function TDRenderer:prepareMeshes()
	for image, imageQueue in pairs(Queue) do
		local mesh = love.graphics.newMesh(VertexFormat, #imageQueue / 3 * 4, "triangles")
		mesh:setTexture(image)

		Meshes[image] = {
			mesh = mesh,
			vertices = {},
			indices = {},
		}
	end
end

function TDRenderer:writeQuadData(image, quadData)
	local mesh = Meshes[image]

	if (not mesh) then
		local _mesh = love.graphics.newMesh(VertexFormat, 10000, "triangles")
		_mesh:setTexture(image)

		Meshes[image] = {
			mesh = _mesh,
			vertices = {},
			indices = {},
		}

		mesh = Meshes[image]
	end

	local i = #mesh.vertices + 1

	local p1 = quadData.topLeft
	local p2 = quadData.topRight
	local p3 = quadData.bottomLeft
	local p4 = quadData.bottomRight

	table.insert(mesh.vertices, { p1.position.x, p1.position.y, p1.position.z, p1.uvs.x, p1.uvs.y })
	table.insert(mesh.vertices, { p2.position.x, p2.position.y, p2.position.z, p2.uvs.x, p2.uvs.y })
	table.insert(mesh.vertices, { p3.position.x, p3.position.y, p3.position.z, p3.uvs.x, p3.uvs.y })
	table.insert(mesh.vertices, { p4.position.x, p4.position.y, p4.position.z, p4.uvs.x, p4.uvs.y })

	table.insert(mesh.indices, i)
	table.insert(mesh.indices, i + 2)
	table.insert(mesh.indices, i + 1)
	table.insert(mesh.indices, i + 1)
	table.insert(mesh.indices, i + 2)
	table.insert(mesh.indices, i + 3)
end

function TDRenderer:writeVertexAndIndexData()
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

	for image, imageQueue in pairs(Queue) do
		for i = 1, #imageQueue, 8 do
			local quad = imageQueue[i]
			local position = imageQueue[i + 1]
			local rotation = imageQueue[i + 2]
			local origin = imageQueue[i + 3]
			pivot:vset(imageQueue[i + 4])
			local kind = imageQueue[i + 5]
			local flipX = imageQueue[i + 6]
			local flipY = imageQueue[i + 7]

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

			if (flipX) then
				u1, u2 = u2, u1
			end

			if (kind == "STANDING") then
				z2 = z2 + ih
				pivot.y = pivot.y + position.z
			end

			local mesh = Meshes[image]

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

			table.insert(mesh.vertices, { p1.x, p1.y, p1.z, u2, v2 })
			table.insert(mesh.vertices, { p2.x, p2.y, p2.z, u1, v2 })
			table.insert(mesh.vertices, { p3.x, p3.y, p3.z, u2, v1 })
			table.insert(mesh.vertices, { p4.x, p4.y, p4.z, u1, v1 })

			local j = (math.floor(i / 8) * 4) + 1
			table.insert(mesh.indices, j)
			table.insert(mesh.indices, j + 2)
			table.insert(mesh.indices, j + 1)
			table.insert(mesh.indices, j + 1)
			table.insert(mesh.indices, j + 2)
			table.insert(mesh.indices, j + 3)
		end
	end

	for _, mesh in pairs(Meshes) do
		mesh.mesh:setVertices(mesh.vertices)
		mesh.mesh:setVertexMap(mesh.indices)
	end
end

function TDRenderer:drawMeshes()
	for _, mesh in pairs(Meshes) do
		mesh.mesh:setVertices(mesh.vertices)
		mesh.mesh:setVertexMap(mesh.indices)
	end

	for _, mesh in pairs(Meshes) do
		love.graphics.draw(mesh.mesh)
	end
end

function TDRenderer:renderScene(camera, sun)
	camera.tdRotation:updateAxis()
	sun.tdRotation:updateAxis()

	local ViewMatrix = CPML.mat4()

	local _cameraEye = camera.transform.position
	local cameraEye = CPML.vec3(_cameraEye.x, _cameraEye.y, _cameraEye.z)

	local _cameraCenter = camera.transform.position:vadd(camera.tdRotation.direction)
	local cameraCenter = CPML.vec3(_cameraCenter.x, _cameraCenter.y, _cameraCenter.z)

	local _cameraUp = camera.tdRotation.up
	local cameraUp = CPML.vec3(_cameraUp.x, _cameraUp.y, _cameraUp.z)

	ViewMatrix:look_at(ViewMatrix, cameraEye, cameraCenter, cameraUp)
	ViewMatrix:translate(ViewMatrix, cameraEye)

	-- local pos = CPML.vec3(camera.transform.position.x, camera.transform.position.y, camera.transform.position.z)
	-- pos.x = math.floor(pos.x)
	-- pos.y = math.floor(pos.y)
	-- pos.z = math.floor(pos.z)

	-- ViewMatrix:look_at(ViewMatrix, pos, pos + camera.transform.direction,
	-- 	camera.transform.up)
	-- ViewMatrix:translate(ViewMatrix, pos)

	Shader:send("view_matrix", "column", ViewMatrix)
	Shader:send("projection_matrix", "column", camera.projection.value)

	local SunViewMatrix = CPML.mat4()

	local _sunEye = sun.transform.position
	local sunEye = CPML.vec3(_sunEye.x, _sunEye.y, _sunEye.z)

	local _sunCenter = sun.transform.position:vadd(sun.tdRotation.direction)
	local sunCenter = CPML.vec3(_sunCenter.x, _sunCenter.y, _sunCenter.z)

	local _sunUp = sun.tdRotation.up
	local sunUp = CPML.vec3(_sunUp.x, _sunUp.y, _sunUp.z)

	SunViewMatrix:look_at(SunViewMatrix, sunEye, sunCenter, sunUp)
	SunViewMatrix:translate(SunViewMatrix, sunEye)

	Shader:send("lightSpace_view_matrix", "column", SunViewMatrix)
	Shader:send("lightSpace_projection_matrix", "column", sun.projection.value)
	Shader:send("shadowmap", Shadowmap.depth)

	love.graphics.setShader(Shader)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setDepthMode("lequal", true)
	love.graphics.setCanvas(DepthBuffer.canvas)
	love.graphics.clear(0, 0, 0, 0, true, true)

	self:drawMeshes()

	love.graphics.setShader()
	love.graphics.setDepthMode()
	love.graphics.setCanvas()
end

function TDRenderer:renderShadowmap(sun)
	sun.tdRotation:updateAxis()

	local ViewMatrix = CPML.mat4()

	local _eye = sun.transform.position
	local eye = CPML.vec3(_eye.x, _eye.y, _eye.z)

	local _center = sun.transform.position:vadd(sun.tdRotation.direction)
	local center = CPML.vec3(_center.x, _center.y, _center.z)

	local _up = sun.tdRotation.up
	local up = CPML.vec3(_up.x, _up.y, _up.z)

	ViewMatrix:look_at(ViewMatrix, eye, center, up)
	ViewMatrix:translate(ViewMatrix, eye)

	ShadowShader:send("view_matrix", "column", ViewMatrix)
	ShadowShader:send("projection_matrix", "column", sun.projection.value)

	love.graphics.setShader(ShadowShader)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setDepthMode("lequal", true)
	love.graphics.setCanvas(Shadowmap.canvas)
	love.graphics.clear(0, 0, 0, 0, true, true)

	self:drawMeshes()

	love.graphics.setShader()
	love.graphics.setDepthMode()
	love.graphics.setCanvas()
end

function TDRenderer:flush(camera, sun)
	-- self:prepareMeshes()
	-- self:writeVertexAndIndexData()
	self:renderShadowmap(sun)
	self:renderScene(camera, sun)
	self:drawCanvas()

	-- love.graphics.setColor(1, 0, 0, 1)
	-- love.graphics.rectangle("fill", 0, 0, 320, 180)
	-- love.graphics.setColor(1, 1, 1, 1)
	-- love.graphics.draw(shadowMesh, 160, 90)

	Queue = {}
	Meshes = {}
end

return TDRenderer
