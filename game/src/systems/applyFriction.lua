local ApplyFriction = ECS.system({
	pool = {"velocity"}
})

function ApplyFriction:update(dt)
	local friction = 15
	local ratio = 1 / (1 + (dt * friction))

	for _, e in ipairs(self.pool) do
		e.velocity.value:smuli(ratio)
	end
end

return ApplyFriction