local SyncQuadData = ECS.system({
	eligible = { "transform", "sprite"},
	pool = { "transform", "sprite", "quadData" }
})

function SyncQuadData:init()
	self.eligible.onAdded = function(_, e)
		e:give("quadData")
		e.quadData:buildLocalData(e.sprite)
	end

	self.eligible.onRemoved = function(_, e)
		e:remove("quadData")
	end
end

function SyncQuadData:update(dt)
	for _, e in ipairs(self.pool) do
		if (e.sprite.kind == "PROP") then
			e.quadData:updateWorldPositionsFromDiagonal(e.transform, e.sprite)
		end

		if (e.sprite.kind == "TILE") then
			e.quadData:updateWorldPositionsFromFlat(e.transform, e.sprite)
		end
	end
end

return SyncQuadData
