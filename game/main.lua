love.graphics.setDefaultFilter("nearest", "nearest")

ECS = require("lib.concord")
Imgui = require("imgui")
Vector = require("lib.vector")
CPML = require("lib.cpml")
TDRenderer = require("src.tdrenderer")
Assemblages = {}

local Systems = {}
ECS.utils.loadNamespace("src/components")
ECS.utils.loadNamespace("src/systems", Systems)
ECS.utils.loadNamespace("src/assemblages", Assemblages)

local World = ECS.world()

World:addSystems(

)

local Camera = ECS.entity(World)
	:assemble(Assemblages.camera, CPML.vec3(0, 0, -50), CPML.vec2(-math.pi, 0), 320, 180)

local Sun = ECS.entity(World)
	:assemble(Assemblages.sun, CPML.vec3(-123.802, 0.000, -223.610), CPML.vec2(-15.337, 0.15), 320, 180)

function love.load()
	World:emit("load")
end

local playerPos = CPML.vec3(0, 0, 0)
local playerVel = CPML.vec3(0, 0, 0)
local flip = false

local img = love.graphics.newImage("assets/tilemap.png")
local sw, sh = img:getDimensions()
local chest = love.graphics.newQuad(85, 119, 16, 16, sw, sh)
local wizard = love.graphics.newQuad(0, 119, 16, 16, sw, sh)
local table = love.graphics.newQuad(0, 101, 16, 16, sw, sh)
local potion = love.graphics.newQuad(119, 153, 16, 16, sw, sh)

local fenceL = love.graphics.newQuad(68, 102, 16, 16, sw, sh)
local fenceM = love.graphics.newQuad(85, 102, 16, 16, sw, sh)
local fenceR = love.graphics.newQuad(102, 102, 16, 16, sw, sh)

local ground = love.graphics.newQuad(0, 68, 16, 16, sw, sh)
local groundVariationA = love.graphics.newQuad(17, 68, 16, 16, sw, sh)
local groundVariationB = love.graphics.newQuad(102, 51, 16, 16, sw, sh)

local wallL = love.graphics.newQuad(153, 68, 16, 16, sw, sh)
local wallM = love.graphics.newQuad(68, 51, 16, 16, sw, sh)
local wallMVar = love.graphics.newQuad(68, 34, 16, 16, sw, sh)
local wallR = love.graphics.newQuad(187, 68, 16, 16, sw, sh)
local stair = love.graphics.newQuad(51, 51, 16, 16, sw, sh)

local wallTopM = love.graphics.newQuad(34, 0, 16, 16, sw, sh)
local wallTopBendTL = love.graphics.newQuad(68, 0, 16, 16, sw, sh)
local wallTopBendTR = love.graphics.newQuad(85, 0, 16, 16, sw, sh)
local wallTopBendBL = love.graphics.newQuad(68, 17, 16, 16, sw, sh)
local wallTopBendBR = love.graphics.newQuad(85, 17, 16, 16, sw, sh)
local wallTopMid = love.graphics.newQuad(0, 0, 16, 16, sw, sh)
local wallTopBack = love.graphics.newQuad(34, 34, 16, 16, sw, sh)



local grave = love.graphics.newQuad(68, 85, 16, 16, sw, sh)

local floorLayout = {}

for x = -10, 20 do
	floorLayout[x] = {}
	for y = -10, 20 do
		local rand = love.math.random(0, 100) / 100

		if (rand < 0.9) then
			floorLayout[x][y] = ground
		elseif (rand < 0.97) then
			floorLayout[x][y] = groundVariationB
		else
			floorLayout[x][y] = groundVariationA
		end
	end
end
function love.update(dt)
	Imgui.NewFrame(true)

	World:emit("update", dt)

	local movementVector = CPML.vec3()
	if love.keyboard.isDown("w") then movementVector = movementVector + Camera.transform.forward end
	if love.keyboard.isDown("s") then movementVector = movementVector - Camera.transform.forward end

	if love.keyboard.isDown("a") then movementVector = movementVector + Camera.transform.right end
	if love.keyboard.isDown("d") then movementVector = movementVector - Camera.transform.right end

	if love.keyboard.isDown("space") then movementVector.y = movementVector.y + 1 end
	if love.keyboard.isDown("lshift") then movementVector.y = movementVector.y - 1 end

	Camera.transform.position = Camera.transform.position + movementVector * 50 * dt


	local speed = 600
	if love.keyboard.isDown("left") then
		playerVel = playerVel + CPML.vec3(-speed, 0, 0) * dt
		flip = true
	end
	if love.keyboard.isDown("right") then
		playerVel = playerVel + CPML.vec3(speed, 0, 0) * dt
		flip = false
	end

	if love.keyboard.isDown("up") then playerVel = playerVel + CPML.vec3(0, speed, 0) * dt end
	if love.keyboard.isDown("down") then playerVel = playerVel + CPML.vec3(0, -speed, 0) * dt end

	if love.keyboard.isDown("q") then playerPos = playerPos + CPML.vec3(0, 0, 10) * dt end
	if love.keyboard.isDown("e") then playerPos = playerPos + CPML.vec3(0, 0, -10) * dt end


	local friction = 15
	local ratio = 1 / (1 + (dt * friction))
	playerVel = playerVel * ratio

	playerPos = playerPos + playerVel * dt
end

function love.draw()
	World:emit("draw")

	TDRenderer:drawStanding(img, table, CPML.vec3(0, 0, 0))
	TDRenderer:drawStanding(img, potion, CPML.vec3(0, -2, 8))

	TDRenderer:drawStanding(img, fenceL, CPML.vec3(-64, -32, 0))
	TDRenderer:drawStanding(img, fenceM, CPML.vec3(-48, -32, 0))
	TDRenderer:drawStanding(img, fenceM, CPML.vec3(-32, -32, 0))
	TDRenderer:drawStanding(img, fenceR, CPML.vec3(-16, -32, 0))

	TDRenderer:drawStanding(img, wizard, playerPos, flip)

	TDRenderer:drawStanding(img, grave, CPML.vec3(48, -16, 0))

	TDRenderer:drawStanding(img, wallL, CPML.vec3(32, 16, 0))
	TDRenderer:drawStanding(img, wallMVar, CPML.vec3(48, 16, 0))
	TDRenderer:drawStanding(img, wallM, CPML.vec3(64, 16, 0))
	TDRenderer:drawStanding(img, stair, CPML.vec3(80, 16, 0))
	TDRenderer:drawStanding(img, wallM, CPML.vec3(96, 16, 0))
	TDRenderer:drawStanding(img, wallR, CPML.vec3(112, 16, 0))

	TDRenderer:drawFlat(img, wallTopBendBL, CPML.vec3(32, 16, 16))
	TDRenderer:drawFlat(img, wallTopM, CPML.vec3(48, 16, 16))
	TDRenderer:drawFlat(img, wallTopM, CPML.vec3(64, 16, 16))
	TDRenderer:drawFlat(img, wallTopMid, CPML.vec3(80, 16, 16))
	TDRenderer:drawFlat(img, wallTopM, CPML.vec3(96, 16, 16))
	TDRenderer:drawFlat(img, wallTopBendBR, CPML.vec3(112, 16, 16))

	TDRenderer:drawFlat(img, wallTopBendTL, CPML.vec3(32, 32, 16))
	TDRenderer:drawFlat(img, wallTopBack, CPML.vec3(48, 32, 16))
	TDRenderer:drawFlat(img, wallTopBack, CPML.vec3(64, 32, 16))
	TDRenderer:drawFlat(img, wallTopBack, CPML.vec3(80, 32, 16))
	TDRenderer:drawFlat(img, wallTopBack, CPML.vec3(96, 32, 16))
	TDRenderer:drawFlat(img, wallTopBendTR, CPML.vec3(112, 32, 16))

	for x = -10, 20 do
		for y = -10, 20 do
			local quad = floorLayout[x][y]
			TDRenderer:drawFlat(img, quad, CPML.vec3(x * 16 - 96, y * 16 - 96, 0))
		end
	end
	TDRenderer:flush(Camera, Sun)
	-- TDRenderer:flush(Sun, Sun)

	Imgui.Render()

	local drawCalls = love.graphics.getStats().drawcalls

	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 0, 0, 200, 100)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Drawcalls: " .. drawCalls, 10, 10)
	love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 30)
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
			local rotationVector = CPML.vec2(-dx, dy)
			Camera.transform.rotation = Camera.transform.rotation + rotationVector / 80
			print(rotationVector)
			-- Sun.rotation = Sun.rotation + rotationVector / 80
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
