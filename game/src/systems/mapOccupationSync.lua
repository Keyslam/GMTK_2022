local MapOccupationSync = ECS.system({
	pool = {"transform", "mapOccupation"},
	dynamic = {"transform", "mapOccupation", "dynamic"}
})

function MapOccupationSync:init()
	local collisionMap = self:getWorld():getResource("collisionMap")

	self.pool.onAdded = function(_, e)
		local tileX, tileY = Utils:worldToTile(e.transform.position.x, e.transform.position.y)

		for _, spot in ipairs(e.mapOccupation.spots) do
			local tileX, tileY = tileX + spot.x, tileY + spot.y
			if (not collisionMap[tileX]) then
				collisionMap[tileX] = {}
			end

			collisionMap[tileX][tileY] = true
			table.insert(e.mapOccupation.occupying, Vec2(tileX, tileY))
		end
	end

	self.pool.onRemoved = function(_, e)
		for i = #e.mapOccupation.occupying, 1, -1 do
			local spot = e.mapOccupation.occupying[i]
			collisionMap[spot.x][spot.y] = nil
			e.mapOccupation.occupying[i] = nil
		end
	end
end

function MapOccupationSync:update(dt)
	for _, e in ipairs(self.dynamic) do
		local collisionMap = self:getWorld():getResource("collisionMap")

		for i = #e.mapOccupation.occupying, 1, -1 do
			local spot = e.mapOccupation.occupying[i]
			collisionMap[spot.x][spot.y] = nil
			e.mapOccupation.occupying[i] = nil
		end

		local tileX, tileY = Utils:worldToTile(e.transform.position.x, e.transform.position.y)

		for _, spot in ipairs(e.mapOccupation.spots) do
			local tileX, tileY = tileX + spot.x, tileY + spot.y
			if (not collisionMap[tileX]) then
				collisionMap[tileX] = {}
			end

			collisionMap[tileX][tileY] = true
			table.insert(e.mapOccupation.occupying, Vec2(tileX, tileY))
		end
	end
end

return MapOccupationSync