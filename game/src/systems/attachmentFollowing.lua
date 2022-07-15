local AttachmentFollowing = ECS.system({
	pool = {"transform", "quadData", "sprite", "attachment"}
})

function AttachmentFollowing:update(dt)
	for _, e in ipairs(self.pool) do

		local attached = e.attachment.attached
		local connectionPoint = e.attachment.connectionPoint

		local p = e.quadData:localPointTo3DPoint(connectionPoint, e.transform, e.sprite)
		p.z = p.z + 8

		attached.transform.position:vset(p)
		-- attached.transform.rotation = e.transform.rotation
		attached.quadData:updateWorldPositions(attached.transform, attached.sprite)
	end
end

return AttachmentFollowing