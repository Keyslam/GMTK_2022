local ControlsMovement = ECS.system({
	pool = {"transform", "velocity", "controls"}
})

function ControlsMovement:update(dt)
	local movementVector = Vec3()

	for _, e in ipairs(self.pool) do
		movementVector:sset(0, 0, 0)

		if love.keyboard.isDown(e.controls.left) then
			movementVector = movementVector:saddi(-1, 0, 0)
		end

		if love.keyboard.isDown(e.controls.right) then
			movementVector = movementVector:saddi(1, 0, 0)
		end

		if love.keyboard.isDown(e.controls.forward) then
			movementVector = movementVector:saddi(0, 1, 0)
		end

		if love.keyboard.isDown(e.controls.backward) then
			movementVector = movementVector:saddi(0, -1, 0)
		end

		movementVector:normalisei()
		movementVector:smuli(e.controls.movementSpeed)
		movementVector:smuli(dt)

		e.velocity.value:vaddi(movementVector)

		if (movementVector:length() > 0.1) then
			e.transform.rotation = math.sin(love.timer.getTime() * 15) * 0.1
		else
			e.transform.rotation = 0
		end
	end
end

return ControlsMovement