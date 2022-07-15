local Aim = ECS.system({
	pool = {"transform", "aiming"}
})

function Aim:update(dt)
	for _, e in ipairs(self.pool) do
		local origin = Vec2(e.transform.position.x, e.transform.position.y)
		local target = e.aiming.target

		local angle = math.atan2((target.y - origin.y), (target.x - origin.x))
		e.transform.rotation = angle
	end
end

return Aim