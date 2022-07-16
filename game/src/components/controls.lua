-- TODO: Make configurable. Support gamepads. Use Baton maybe?
local Controls = ECS.component("controls", function(e)
	e.forward = "w"
	e.backward = "s"
	e.left = "a"
	e.right = "d"

	e.enabled = false

	e.lastInput = nil
end)