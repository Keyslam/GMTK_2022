ECS = require("lib.concord")
Imgui = require("imgui")
Vector = require("lib.vector")
Assemblages = {}

local Systems = {}
ECS.utils.loadNamespace("src/components")
ECS.utils.loadNamespace("src/systems", Systems)
ECS.utils.loadNamespace("src/assemblages", Assemblages)

local World = ECS.world()

World:addSystems(

)

function love.load()
	World:emit("load")
end

function love.update(dt)
	Imgui.NewFrame(true)

	World:emit("update", dt)
end

function love.draw()
	World:emit("draw")

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
