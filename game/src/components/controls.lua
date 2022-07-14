-- TODO: Make configurable. Support gamepads. Use Baton maybe?
local Controls = ECS.component("controls", function(e)
	e.forward = "w"
	e.backward = "s"
	e.left = "a"
	e.right = "d"

	e.movementSpeed = 600 -- TODO: Move this out? I don't think it belongs here
end)