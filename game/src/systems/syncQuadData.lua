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
		e.quadData:updateWorldPositions(e.transform, e.sprite)
		e.quadData:updateUvs(e.sprite)
	end
end

return SyncQuadData
