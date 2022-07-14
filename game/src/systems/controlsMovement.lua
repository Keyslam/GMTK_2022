local ControlsMovement = ECS.system({
	pool = {"transform", "velocity", "controls"}
})

function ControlsMovement:update(dt)
	for _, e in ipairs(self.pool) do
		local movementVector = CPML.vec3(0, 0, 0)

		if love.keyboard.isDown(e.controls.left) then
			movementVector = movementVector + CPML.vec3(-1, 0, 0)
		end

		if love.keyboard.isDown(e.controls.right) then
			movementVector = movementVector + CPML.vec3(1, 0, 0)
		end

		if love.keyboard.isDown(e.controls.forward) then
			movementVector = movementVector + CPML.vec3(0, 1, 0, 0)
		end

		if love.keyboard.isDown(e.controls.backward) then
			movementVector = movementVector + CPML.vec3(0, -1, 0, 0)
		end

		movementVector:normalize()
		movementVector = movementVector * e.controls.movementSpeed

		e.velocity.value = e.velocity.value + movementVector * dt
	end
end

return ControlsMovement