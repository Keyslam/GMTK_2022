love.graphics.setDefaultFilter("nearest", "nearest")
love.mouse.setVisible(false)

local SheetLoader = require("src.sheetLoader")
local Batteries = require("lib.batteries")
local MapBuilder = require("src.mapBuilder")

ECS = require("lib.concord")
Imgui = require("imgui")
Vector = require("lib.vector")
CPML = require("lib.cpml")
Peachy = require("lib.peachy")
TDRenderer = require("src.tdrenderer")
Utils = require("src.utils")
CommandSequencer = require("src.commandSequencer")
Vec3 = Batteries.vec3
Vec2 = Batteries.vec2
Assemblages = {}

local Systems = {}
ECS.utils.loadNamespace("src/components")
ECS.utils.loadNamespace("src/systems", Systems)
ECS.utils.loadNamespace("src/assemblages", Assemblages)

local World = ECS.world()

World:setResource("collisionMap", {})

World:addSystems(
	Systems.controlsMovement,
	Systems.createOrDestroyMoveIndicators,
	Systems.mapOccupationSync,

	Systems.cameraFollowing,

	Systems.syncQuadData,

	Systems.updateAnimatedSprites,
	Systems.spriteRendering
)


local Tilemap = SheetLoader:loadSheet("assets/tilemap.png", require("assets.tilemap"))
local Cards = SheetLoader:loadSheet("assets/cards.png", require("assets.cards"))
local Crosshairs = SheetLoader:loadSheet("assets/crosshairs.png", require("assets.crosshairs"))
local Meeple = SheetLoader:loadSheet("assets/meeple.png", require("assets.meeple"))

local Player = ECS.entity(World)
	:assemble(Assemblages.player, Meeple.image, Meeple.quads.idle, Vec3(0, 0, 0), Vec2(0, -9))

local Camera = ECS.entity(World)
	:assemble(Assemblages.camera, Vec3(0, 0, -500), Vec2(-math.pi, 0), 640, 360, nil, nil, Player)

local Sun = ECS.entity(World)
	:assemble(Assemblages.sun, Vec3(-123.802, 0.000, -223.610), Vec2(-15.337, 0.3), 640, 360)

local Crosshair = ECS.entity(World)
	:assemble(Assemblages.crosshair, Crosshairs.image, Crosshairs.quads.tile_1x1_valid, Vec3(0, 0, 0.1))

-- local Dice = ECS.entity(World)
-- 	:assemble(Assemblages.prop)

local mapData = MapBuilder:build(30, 30)
MapBuilder:populateECS(mapData, World)

local state
local states = {}

function states.roll()
	print("Waiting for roll input")
	while ( not love.keyboard.isDown("space")) do
		coroutine.yield()
	end
	print("Rolled")
	local roll = love.math.random(1, 6)
	print(roll)

	state = CommandSequencer:enqueue(states.move, roll)
end

function states.move(actionAmount)
	Player.actions:setShowIndicators(true)
	Player.controls.enabled = true
	Player.actions.amount = actionAmount
	print("Waiting for moves")

	while (Player.actions.amount > 0) do
		coroutine.yield()
	end

	print("moved")

	state = CommandSequencer:enqueue(states.roll)
end

CommandSequencer:enqueue(states.roll)

function love.load()
	World:emit("load")
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

	CommandSequencer:update()
	World:emit("update", dt)

	local cursorX, cursorY = love.mouse.getPosition()
	cursorX = ((cursorX - (1920 / 2)) / 1920) * 640
	cursorY = ((cursorY - (1080 / 2)) / 1080) * 360
	cursorX = cursorX - Camera.transform.position.x
	cursorY = cursorY * -1
	cursorY = cursorY - Camera.transform.position.y

	local tileX, tileY = Utils:worldToTile(cursorX, cursorY)

	if ((tileX == 1 and tileY == 0) or (tileX == -1 and tileY == 0) or (tileX == 0 and tileY == 1) or (tileX == 0 and tileY == -1)) then
		Crosshair.sprite.quad = Crosshairs.quads.tile_1x1_valid
	else
		Crosshair.sprite.quad = Crosshairs.quads.tile_1x1_invalid
	end

	local worldX, worldY = Utils:tileToWorld(tileX, tileY)
	Crosshair.transform.position:sset(worldX, worldY, 0.1)
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
