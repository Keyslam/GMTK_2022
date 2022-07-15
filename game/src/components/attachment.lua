local Attachment = ECS.component("attachment", function(e, attached, connectionPoint)
	e.attached = attached
	e.connectionPoint = connectionPoint
end)