local Actions = ECS.component("actions", function(e, amount, showIndicators)
	e.amount = 0
	e.showIndicators = false

	e.lastShowIndicators = not false

	e.moveIndicators = {}
end)

function Actions:setShowIndicators(v)
	self.lastShowIndicators = self.showIndicators
	self.showIndicators = v
end

