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
	Systems.controlsMovement,
	Systems.velocityIntegration,

	Systems.spriteRendering
)

local img = love.graphics.newImage("assets/tilemap.png")
local sw, sh = img:getDimensions()
local wizard = love.graphics.newQuad(0, 119, 16, 16, sw, sh)

local Camera = ECS.entity(World)
	:assemble(Assemblages.camera, CPML.vec3(0, 0, -500), CPML.vec2(-math.pi, 0), 640, 360)

local Sun = ECS.entity(World)
	:assemble(Assemblages.sun, CPML.vec3(-123.802, 0.000, -223.610), CPML.vec2(-15.337, 0.3), 640, 360)

local Player = ECS.entity(World)
	:assemble(Assemblages.player, img, wizard, CPML.vec3(0, 0, 0))

function love.load()
	World:emit("load")
end

local playerPos = CPML.vec3(0, 0, 0)
local playerVel = CPML.vec3(0, 0, 0)
local flip = false

local imgSpider = love.graphics.newImage("assets/spider.png")
local ssw, ssh = imgSpider:getDimensions()
local spiderHead = love.graphics.newQuad(0, 0, 82, 38, ssw, ssh)
local spiderHip = love.graphics.newQuad(83, 0, 42, 38, ssw, ssh)
local spiderKnee = love.graphics.newQuad(126, 0, 10, 44, ssw, ssh)


local chest = love.graphics.newQuad(85, 119, 16, 16, sw, sh)
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

for x = -10, 20 do
	for y = -10, 20 do
		local rand = love.math.random()
		local quad = rand < 0.9 and ground or rand < 0.97 and groundVariationA or groundVariationB

		ECS.entity(World)
		:assemble(Assemblages.tile, img, quad, CPML.vec3(x * 16, y * 16, 0))
	end
end

function love.update(dt)
	Imgui.NewFrame(true)

	World:emit("update", dt)

	local movementVector = CPML.vec3()
	-- if love.keyboard.isDown("w") then movementVector = movementVector + Camera.transform.forward end
	-- if love.keyboard.isDown("s") then movementVector = movementVector - Camera.transform.forward end

	-- if love.keyboard.isDown("a") then movementVector = movementVector + Camera.transform.right end
	-- if love.keyboard.isDown("d") then movementVector = movementVector - Camera.transform.right end

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

	-- TDRenderer:drawStanding(imgSpider, spiderKnee, CPML.vec3(30, -30, 0), true)
	-- TDRenderer:drawStanding(imgSpider, spiderHip, CPML.vec3(36, -30, 44), true)
	-- TDRenderer:drawStanding(imgSpider, spiderHead, CPML.vec3(30 + 30, -30, 44 + 38 - 12))

	TDRenderer:flush(Camera, Sun)

	if (Imgui.Begin("Debug")) then
		local fps = love.timer.getFPS()
		local stats = love.graphics.getStats()

		Imgui.Text("FPS: " ..fps)
		Imgui.Text("Drawcalls: " ..stats.drawcalls)
		
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
