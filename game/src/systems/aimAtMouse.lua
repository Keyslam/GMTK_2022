local AimAtMouse = ECS.system({
	pool = {"aiming", "aimAtMouse"}
})

function AimAtMouse:update(dt)
	for _, e in ipairs(self.pool) do
		local mx, my = love.mouse.getPosition()
		mx = mx - 1920/2
		my = my - 1080/2
		e.aiming.target = Vec2(mx, -my)
	end
end

return AimAtMouse