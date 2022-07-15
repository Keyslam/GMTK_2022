love.graphics.setDefaultFilter("nearest", "nearest")

local SheetLoader = require("src.sheetLoader")
local Batteries = require("lib.batteries")

ECS = require("lib.concord")
Imgui = require("imgui")
Vector = require("lib.vector")
CPML = require("lib.cpml")
Peachy = require("lib.peachy")
TDRenderer = require("src.tdrenderer")
Vec3 = Batteries.vec3
Vec2 = Batteries.vec2
Assemblages = {}

local Systems = {}
ECS.utils.loadNamespace("src/components")
ECS.utils.loadNamespace("src/systems", Systems)
ECS.utils.loadNamespace("src/assemblages", Assemblages)

local World = ECS.world()

World:addSystems(
	Systems.controlsMovement,
	Systems.velocityIntegration,
	Systems.applyFriction,
	Systems.syncQuadData,
	Systems.ikSolving,

	Systems.updateAnimatedSprites,
	Systems.spriteRendering
)

local Tilemap = SheetLoader:loadSheet("assets/tilemap.png", require("assets.tilemap"))
local Point = SheetLoader:loadSheet("assets/point.png", require("assets.point"))
local Spider = SheetLoader:loadSheet("assets/spider.png", require("assets.spider"))
local CountAndColours = love.graphics.newImage("assets/countAndColours.png")

local Camera = ECS.entity(World)
	:assemble(Assemblages.camera, Vec3(0, 0, -500), Vec2(-math.pi, 0), 640, 360)

-- local Camera = ECS.entity(World)
-- 	:assemble(Assemblages.debugCamera)

local Sun = ECS.entity(World)
	:assemble(Assemblages.sun, Vec3(-123.802, 0.000, -223.610), Vec2(-15.337, 0.3), 640, 360)

local Player = ECS.entity(World)
	:assemble(Assemblages.player, Tilemap.image, Tilemap.quads.wizard, Vec3(0, 0, 8), Vec3(0, 0, 0))

-- local Chest= ECS.entity(World)
-- 	:assemble(Assemblages.prop, Tilemap.image, Tilemap.quads.chest_closed, Vec3(0, 0, 0))

-- local Num = ECS.entity(World)
-- 	:assemble(Assemblages.animatedProp, CountAndColours, "assets/countAndColours.json", "Numbers", Vec3(32, 0, 0))

-- local SpiderHead = ECS.entity(World)
-- 	:assemble(Assemblages.prop, Spider.image, Spider.quads.head, Vec3(0, 0, 20), Vec3(0, -19, 0))

-- local SpiderHipLeft = ECS.entity(World)
-- 	:assemble(Assemblages.prop, Spider.image, Spider.quads.hip, Vec3(0, 0, 8), Vec3(20.5, 18.5, 0))

-- local SpiderKneeLeft = ECS.entity(World)
-- 	:assemble(Assemblages.prop, Spider.image, Spider.quads.knee, Vec3(0, 0, 22), Vec3(2.5, 21.5, 0))

-- -- local rootConnection = Vec3(-17.5, -11.5, 0)
-- -- local rootConnection = Vec3(-35.5, -3.5, 0)

-- local SpiderLeftIK = ECS.entity(World)
-- 	:assemble(Assemblages.ik, SpiderHead, Vec3(-17.5, -11.5, 0), SpiderHipLeft, Vec3(-20.5, 18.5, -18.5), SpiderKneeLeft)


local p = Vec3(0, 0, 0)
-- p:vaddi(o):vaddi(rootConnection):vaddi(Vec3(0, 0, 7.5))

ECS.entity(World)
	:assemble(Assemblages.prop, Point.image, Point.quads.red, p, Vec3(0, 0, 0), Vec3(0, 0, 0))

	-- local SpiderHipRight = ECS.entity(World)
-- 	:assemble(Assemblages.prop, Spider.image, Spider.quads.hip, Vec3(100, 0, 20))

-- local SpiderKneeRight = ECS.entity(World)
-- 	:assemble(Assemblages.prop, Spider.image, Spider.quads.knee, Vec3(100, 0, 20))

function love.load()
	World:emit("load")
end

for x = -10, 20 do
	for y = -10, 20 do
		local rand = love.math.random()
		local quad = rand < 0.9 and Tilemap.quads.sand_1 or rand < 0.97 and Tilemap.quads.sand_2 or Tilemap.quads.sand_3

		ECS.entity(World)
			:assemble(Assemblages.tile, Tilemap.image, quad, Vec3(x * 16, y * 16, 0))
	end
end

function love.update(dt)
	Imgui.NewFrame(true)

	local movementVector = Vec3(0, 0, 0)
	if love.keyboard.isDown("space") then movementVector:vaddi(Camera.tdRotation.forward) end
	if love.keyboard.isDown("lshift") then movementVector:vsubi(Camera.tdRotation.forward) end

	if love.keyboard.isDown("right") then movementVector:vaddi(Camera.tdRotation.right) end
	if love.keyboard.isDown("left") then movementVector:vsubi(Camera.tdRotation.right) end

	if love.keyboard.isDown("down") then movementVector.y = movementVector.y + 1 end
	if love.keyboard.isDown("up") then movementVector.y = movementVector.y - 1 end

	movementVector:smuli(50)
	movementVector:smuli(dt)
	Camera.transform.position:vaddi(movementVector)

	World:emit("update", dt)

	-- local rootConnection = Vec3(-17.5, 7.5, 0)
	-- do
	-- 	local piv = Vec3():vset(SpiderHead.sprite.pivot)
	-- 	local ix, iy, iw, ih = SpiderHead.sprite.quad:getViewport()
	-- 	piv.z = piv.z + (piv.y/(ih/2) * ih/2)
	-- 	SpiderHead.quadData:localToWorld(rootConnection, SpiderHead.transform.position, piv, SpiderHead.transform.rotation)
	-- 	print(rootConnection)
	-- 	-- print(rootConnection)
	-- end
	-- p:vset(rootConnection)
	-- -- p:vset(SpiderHead.quadData.topLeft.position)
	-- p.y = SpiderHead.transform.position.y
	-- print(SpiderHead.transform.position.z)
	-- p:ssubi(0, SpiderHead.transform.position.z * 2, 0)
	-- p:ssubi(0, 0, 0)

	local pivotDiagonal = Vec3():vset(Player.sprite.pivotDiagonal)
	local normalDiagonal = Vec3():vset(Player.quadData.diagonalNormal)
	local origin = Vec3(0, -8, 0)
	local out = Player.sprite:spriteToWorldSprite(origin)
	local diagonalHipConnection = Vec3():vset(Player.quadData:localToWorldNoZ(out, Player.transform.position, pivotDiagonal, Player.transform.rotation, normalDiagonal))
	-- print(out, diagonalHipConnection)


	-- local pivotDiagonal = Vec3():vset(Player.sprite.pivotDiagonal)
	-- local normalDiagonal = Vec3():vset(Player.quadData.diagonalNormal)
	-- local diagonalHipConnection = Vec3():vset(Player.quadData:localToWorldNoZ(origin, Player.transform.position, pivotDiagonal, Player.transform.rotation, normalDiagonal))
	p:vset(diagonalHipConnection)
	-- print(Player.quadData.flatNormal)
	-- p:sset(-38, -11, 100)

	-- SpiderHead.transform.position = Vec3(0, 0, (math.sin(love.timer.getTime()) + 1) * 10 + 100)
end

function love.draw()
	World:emit("draw")

	TDRenderer:flush(Camera, Sun)

	if (Imgui.Begin("Debug")) then
		local fps = love.timer.getFPS()
		local stats = love.graphics.getStats()

		Imgui.Text("FPS: " .. fps)
		Imgui.Text("Drawcalls: " .. stats.drawcalls)

		Imgui.End()
	end

	Imgui.Render()
end

function love.quit()
	World:emit("quit")

	Imgui.ShutDown()
end

function love.mousepressed(x, y, button)
	Imgui.MousePressed(button)

	if (not Imgui.GetWantCaptureMouse()) then
		local event = {
			x = x,
			y = y,
			button = button,
			consumed = false,
		}

		World:emit("mousepressed", event)
	end
end

function love.mousereleased(x, y, button)
	Imgui.MouseReleased(button)

	if (not Imgui.GetWantCaptureMouse()) then
		local event = {
			x = x,
			y = y,
			button = button,
			consumed = false,
		}

		World:emit("mousereleased", event)
	end
end

function love.mousemoved(x, y, dx, dy)
	Imgui.MouseMoved(x, y)

	if (not Imgui.GetWantCaptureMouse()) then
		local event = {
			x = x,
			y = y,
			dx = dx,
			dy = dy,
			consumed = false,
		}

		World:emit("mousemoved", event)

		if love.mouse.getRelativeMode() then
			local rotationVector = Vec3(-dx, dy)
			Camera.tdRotation.rotation:vaddi(rotationVector:sdivi(80))
		end
	end
end

function love.wheelmoved(dx, dy)
	Imgui.WheelMoved(dy)

	if (not Imgui.GetWantCaptureMouse()) then
		local event = {
			dx = dx,
			dy = dy,
			consumed = false,
		}

		World:emit("wheelmoved", event)
	end
end

function love.textinput(t)
	Imgui.TextInput(t)

	if (not Imgui.GetWantCaptureKeyboard()) then
		local event = {
			t = t,
			consumed = false,
		}

		World:emit("textinput", event)
	end
end

function love.keypressed(key, scancode, isrepeat)
	Imgui.KeyPressed(key)

	if (not Imgui.GetWantCaptureKeyboard()) then
		local event = {
			key = key,
			scancode = scancode,
			isrepeat = isrepeat,
			consumed = false,
		}

		if (key == "t") then
			love.mouse.setRelativeMode(not love.mouse.getRelativeMode())
		end

		World:emit("keypressed", event)
	end
end

function love.keyreleased(key, scancode)
	Imgui.KeyReleased(key)

	if (not Imgui.GetWantCaptureKeyboard()) then
		local event = {
			key = key,
			scancode = scancode,
			consumed = false,
		}

		World:emit("keyreleased", event)
	end
end
