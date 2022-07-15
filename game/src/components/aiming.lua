local Aiming = ECS.component("aiming", function(e, target, eye)
	e.target = target
	e.eye = eye
end)