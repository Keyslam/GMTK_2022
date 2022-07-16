local CreateOrDestroyMoveIndicators = ECS.system({
	pool = {"transform", "actions"}
})

function CreateOrDestroyMoveIndicators:update(dt)
	for _, e in ipairs(self.pool) do
		if (e.actions.showIndicators ~= e.actions.lastShowIndicators) then
			if (e.actions.showIndicators) then
				local offsets = {
					{x = -32, y = 0},
					{x =  32, y = 0},
					{x =   0, y = -32},
					{x =   0, y = 32},
				}

				for _, offset in ipairs(offsets) do
					local x = e.transform.position.x + offset.x
					local y = e.transform.position.y + offset.y

					local indicator = ECS.entity(self:getWorld())
						:assemble(Assemblages.moveIndicator, Vec3(x, y, 0.1))

					table.insert(e.actions.moveIndicators, indicator)
				end
			end

			if (not e.actions.showIndicators) then
				for i = 1, #e.actions.moveIndicators do
					local indicator = e.actions.moveIndicators[i]
					e.actions.moveIndicators[i] = nil
					indicator:destroy()
				end
			end
		end
	end
end

return CreateOrDestroyMoveIndicators