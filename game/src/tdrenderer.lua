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
	{ 320, -180,  0, 1,  1, 1, 1, 1},
	{-320, -180,  1, 1,  1, 1, 1, 1},
	{ 320,  180,  0, 0,  1, 1, 1, 1},
	{-320,  180,  1, 0,  1, 1, 1, 1},
 }, "triangles")
 shadowMesh:setVertexMap({
	1,  3,  2,  2,  3,  4,
 })
 shadowMesh:setTexture(Shadowmap.depth)

function TDRenderer:drawFlat(image, quad, position, flipX, flipY)
	if (flipX == nil) then flipX = false end
	if (flipY == nil) then flipY = false end

	if (not Queue[image]) then
		Queue[image] = {}
	end

	table.insert(Queue[image], quad)
	table.insert(Queue[image], position)
	table.insert(Queue[image], "FLAT")
	table.insert(Queue[image], flipX)
	table.insert(Queue[image], flipY)
end

function TDRenderer:drawStanding(image, quad, position, flipX, flipY)
	if (flipX == nil) then flipX = false end
	if (flipY == nil) then flipY = false end

	if (not Queue[image]) then
		Queue[image] = {}
	end

	table.insert(Queue[image], quad)
	table.insert(Queue[image], position)
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

function TDRenderer:writeVertexAndIndexData()
	for image, imageQueue in pairs(Queue) do
		for i = 1, #imageQueue, 5 do
			local quad = imageQueue[i]
			local position = imageQueue[i + 1]
			local kind = imageQueue[i + 2]
			local flipX = imageQueue[i + 3]
			local flipY = imageQueue[i + 4]

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
			end

			local mesh = Meshes[image]

			table.insert(mesh.vertices, { x2, y1, z1, u2, v2 })
			table.insert(mesh.vertices, { x1, y1, z1, u1, v2 })
			table.insert(mesh.vertices, { x2, y2, z2, u2, v1 })
			table.insert(mesh.vertices, { x1, y2, z2, u1, v1 })

			local j = (math.floor(i / 5) * 4) + 1
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
		love.graphics.draw(mesh.mesh)
	end
end

function TDRenderer:renderScene(camera, sun)
	camera.transform:updateAxis()
	sun.transform:updateAxis()

	local ViewMatrix = CPML.mat4()

	local pos = CPML.vec3(camera.transform.position.x, camera.transform.position.y, camera.transform.position.z)
	pos.x = math.floor(pos.x)
	pos.y = math.floor(pos.y)
	pos.z = math.floor(pos.z)

	ViewMatrix:look_at(ViewMatrix, pos, pos + camera.transform.direction,
		camera.transform.up)
	ViewMatrix:translate(ViewMatrix, pos)

	Shader:send("view_matrix", "column", ViewMatrix)
	Shader:send("projection_matrix", "column", camera.projection.value)

	local SunViewMatrix = CPML.mat4()

	SunViewMatrix:look_at(SunViewMatrix, sun.transform.position, sun.transform.position + sun.transform.direction, sun.transform.up)
	SunViewMatrix:translate(SunViewMatrix, sun.transform.position)

	Shader:send("lightSpace_view_matrix",       "column", SunViewMatrix)
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
	sun.transform:updateAxis()

	local ViewMatrix = CPML.mat4()

	ViewMatrix:look_at(ViewMatrix, sun.transform.position, sun.transform.position + sun.transform.direction,
		sun.transform.up)
	ViewMatrix:translate(ViewMatrix, sun.transform.position)

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
	self:prepareMeshes()
	self:writeVertexAndIndexData()
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
