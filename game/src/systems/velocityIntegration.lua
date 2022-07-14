local VelocityIntegration = ECS.system({
	pool = {"transform", "velocity"}
})

function VelocityIntegration:update(dt)
	local velocity = Vec3()

	for _, e in ipairs(self.pool) do
		velocity:vset(e.velocity.value)
		velocity:smuli(dt)
		e.transform.position:vaddi(velocity)
	end
end

return VelocityIntegration