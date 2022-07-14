local VelocityIntegration = ECS.system({
	pool = {"transform", "velocity"}
})

function VelocityIntegration:update(dt)
	for _, e in ipairs(self.pool) do
		e.transform.position = e.transform.position + e.velocity.value * dt
	end
end

return VelocityIntegration