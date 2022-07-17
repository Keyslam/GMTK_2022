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

function TDRenderer:drawCanvas()
	love.graphics.draw(DepthBuffer.color, 0, 0, 0, love.graphics.getWidth() / 1920, love.graphics.getHeight() / 1080)
end

function TDRenderer:prepareMeshes()
	for image, imageQueue in pairs(Queue) do
		local mesh = love.graphics.newMesh(VertexFormat, #imageQueue * 4, "triangles")
		mesh:setTexture(image)

		Meshes[image] = {
			mesh = mesh,
			vertices = {},
			indices = {},
		}
	end
end

function TDRenderer:queueQuadData(image, quadData)
	if (not Queue[image]) then
		Queue[image] = {}
	end

	table.insert(Queue[image], quadData)
end

function TDRenderer:writeVertexAndIndexData()
	for image, quadDataQueue in pairs(Queue) do
		local mesh = Meshes[image]

		for _, quadData in ipairs(quadDataQueue) do
			local i = #mesh.vertices + 1

			local p1 = quadData.topLeft
			local p2 = quadData.topRight
			local p3 = quadData.bottomLeft
			local p4 = quadData.bottomRight

			table.insert(mesh.vertices, { p1.worldPosition.x, p1.worldPosition.y, p1.worldPosition.z, p1.uvs.x, p1.uvs.y })
			table.insert(mesh.vertices, { p2.worldPosition.x, p2.worldPosition.y, p2.worldPosition.z, p2.uvs.x, p2.uvs.y })
			table.insert(mesh.vertices, { p3.worldPosition.x, p3.worldPosition.y, p3.worldPosition.z, p3.uvs.x, p3.uvs.y })
			table.insert(mesh.vertices, { p4.worldPosition.x, p4.worldPosition.y, p4.worldPosition.z, p4.uvs.x, p4.uvs.y })

			table.insert(mesh.indices, i)
			table.insert(mesh.indices, i + 2)
			table.insert(mesh.indices, i + 1)
			table.insert(mesh.indices, i + 1)
			table.insert(mesh.indices, i + 2)
			table.insert(mesh.indices, i + 3)
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

function TDRenderer:updateAxis(cam)
	cam.direction = Vec3(
		math.cos(cam.rotation.y) * math.sin(cam.rotation.x),
		math.sin(cam.rotation.y),
		math.cos(cam.rotation.y) * math.cos(cam.rotation.x)
	)

	cam.right = Vec3(
		math.sin(cam.rotation.x - math.pi / 2),
		0,
		math.cos(cam.rotation.x - math.pi / 2)
	)

	cam.forward = Vec3(
		math.sin(cam.rotation.x + math.pi),
		0,
		math.cos(cam.rotation.x + math.pi)
	)

	cam.up = Vec3.cross(cam.right, cam.direction)
end

function TDRenderer:renderScene(camera, sun)
	self:updateAxis(camera)
	self:updateAxis(sun)

	local ViewMatrix = CPML.mat4()

	local _cameraEye = camera.position
	local cameraEye = CPML.vec3(_cameraEye.x, _cameraEye.y, _cameraEye.z)

	local _cameraCenter = camera.position:vadd(camera.direction)
	local cameraCenter = CPML.vec3(_cameraCenter.x, _cameraCenter.y, _cameraCenter.z)

	local _cameraUp = camera.up
	local cameraUp = CPML.vec3(_cameraUp.x, _cameraUp.y, _cameraUp.z)

	ViewMatrix:look_at(ViewMatrix, cameraEye, cameraCenter, cameraUp)
	ViewMatrix:translate(ViewMatrix, cameraEye)

	Shader:send("view_matrix", "column", ViewMatrix)
	Shader:send("projection_matrix", "column", camera.projection)

	local SunViewMatrix = CPML.mat4()

	local _sunEye = sun.position
	local sunEye = CPML.vec3(_sunEye.x, _sunEye.y, _sunEye.z)

	local _sunCenter = sun.position:vadd(sun.direction)
	local sunCenter = CPML.vec3(_sunCenter.x, _sunCenter.y, _sunCenter.z)

	local _sunUp = sun.up
	local sunUp = CPML.vec3(_sunUp.x, _sunUp.y, _sunUp.z)

	SunViewMatrix:look_at(SunViewMatrix, sunEye, sunCenter, sunUp)
	SunViewMatrix:translate(SunViewMatrix, sunEye)

	Shader:send("lightSpace_view_matrix", "column", SunViewMatrix)
	Shader:send("lightSpace_projection_matrix", "column", sun.projection)
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
	self:updateAxis(sun)

	local ViewMatrix = CPML.mat4()

	local _eye = sun.position
	local eye = CPML.vec3(_eye.x, _eye.y, _eye.z)

	local _center = sun.position:vadd(sun.direction)
	local center = CPML.vec3(_center.x, _center.y, _center.z)

	local _up = sun.up
	local up = CPML.vec3(_up.x, _up.y, _up.z)

	ViewMatrix:look_at(ViewMatrix, eye, center, up)
	ViewMatrix:translate(ViewMatrix, eye)

	ShadowShader:send("view_matrix", "column", ViewMatrix)
	ShadowShader:send("projection_matrix", "column", sun.projection)

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

	Queue = {}
	Meshes = {}
end

return TDRenderer
