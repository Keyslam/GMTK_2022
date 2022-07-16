local ControlsMovement = ECS.system({
	pool = { "transform", "controls", "actions" }
})

local function move(e, x, y, z, r, t)
	local startPosition = Vec3(e.transform.position.x, e.transform.position.y, e.transform.position.z)
	local targetPosition = Vec3(e.transform.position.x + x, e.transform.position.y + y, e.transform.position.z + z)
	local startRotation = e.transform.rotation

	local s = love.timer.getTime()
	while (love.timer.getTime() - s < t) do
		local progress = (love.timer.getTime() - s) / t
		e.transform.position.x = Utils:lerp(startPosition.x, targetPosition.x, progress)
		e.transform.position.y = Utils:lerp(startPosition.y, targetPosition.y, progress)
		e.transform.position.z = Utils:lerp(startPosition.z, targetPosition.z, progress)
		e.transform.rotation = Utils:lerp(startRotation, r, progress)
		coroutine.yield()
	end

	e.transform.position.x = targetPosition.x
	e.transform.position.y = targetPosition.y
	e.transform.position.z = targetPosition.z
	e.transform.rotation = r
end

local function handleInput(e, world, input)
	local dx, dy = 0, 0

	if (input == e.controls.forward) then
		dy = 32
	end

	if (input == e.controls.backward) then
		dy = -32
	end

	if (input == e.controls.left) then
		dx = -32
	end

	if (input == e.controls.right) then
		dx = 32
	end

	if (dx ~= 0 or dy ~= 0) then
		local tileX, tileY = Utils:worldToTile(e.transform.position.x + dx, e.transform.position.y + dy)
		local collisionMap = world:getResource("collisionMap")

		if (not (collisionMap[tileX] and collisionMap[tileX][tileY])) then
			CommandSequencer:enqueue(function()
				e.controls.enabled = false
				e.actions:setShowIndicators(false)

				local moveUp = CommandSequencer:enqueue(move, e, 0, 0, 10, 0.4, 0.08)
				while (not moveUp.done) do coroutine.yield() end

				local moveRight = CommandSequencer:enqueue(move, e, dx, dy, 0, -0.4, 0.08)
				while (not moveRight.done) do coroutine.yield() end

				local moveDown = CommandSequencer:enqueue(move, e, 0, 0, -10, 0, 0.08)
				while (not moveDown.done) do coroutine.yield() end

				e.actions.amount = e.actions.amount - 1

				if (e.actions.amount > 0) then
					e.controls.enabled = true
					e.actions:setShowIndicators(true)
				end
			end)
		end
	end
end

function ControlsMovement:update()
	for _, e in ipairs(self.pool) do
		if (e.controls.enabled) then
			if (e.controls.lastInput) then
				local key = e.controls.lastInput
				e.controls.lastInput = nil
				handleInput(e, self:getWorld(), key)
			end
		end
	end
end

function ControlsMovement:keypressed(event)
	for _, e in ipairs(self.pool) do
		if (not e.controls.enabled) then
			e.controls.lastInput = event.key

			goto continue
		end

		handleInput(e, self:getWorld(), event.key)

		-- Disable controls
		-- Hide movement markers
		-- Move up
		-- Move right
		-- Move down
		-- Knock over whatever piece was there
		-- Decrement turn
		-- If turns > 0
		-- Enable controls
		-- Show movement markers

		::continue::
	end
end

return ControlsMovement
