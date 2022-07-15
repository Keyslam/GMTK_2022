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

	Systems.updateAnimatedSprites,
	Systems.spriteRendering
)

local Tilemap = SheetLoader:loadSheet("assets/tilemap.png", require("assets.tilemap"))
local Point = SheetLoader:loadSheet("assets/point.png", require("assets.point"))
local CountAndColours = love.graphics.newImage("assets/countAndColours.png")

local Camera = ECS.entity(World)
	:assemble(Assemblages.camera, Vec3(0, 0, -500), Vec2(-math.pi, 0), 640, 360)

-- local Camera = ECS.entity(World)
-- 	:assemble(Assemblages.debugCamera)

local Sun = ECS.entity(World)
	:assemble(Assemblages.sun, Vec3(-123.802, 0.000, -223.610), Vec2(-15.337, 0.3), 640, 360)

local Player = ECS.entity(World)
	:assemble(Assemblages.player, Tilemap.image, Tilemap.quads.wizard, Vec3(0, 0, 0), Vec2(0, -8))

local Numbers = ECS.entity(World)
	:assemble(Assemblages.animatedProp, CountAndColours, "assets/countAndColours.json", "PingPong", Vec3(0, 0, 0), Vec2(0, -20), false, false)

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
