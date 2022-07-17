local Entity = require("src.objects.entity")

local DiceRoller = Class("DiceRoller", Entity)

function DiceRoller:initialize()
end

local function roll(self, dices)
	local sum, rolls = 0, 1

	while (rolls > 0) do
		while (not love.keyboard.isDown("space")) do
			coroutine.yield()
		end

		for _, realDice in ipairs(dice.levels) do
			local diceOptions = realDice[level]
			local i = love.math.random(1, #diceOptions)
			local rolledDice = diceOptions[i]
			rolls = rolls - 1

			sum, rolls = rolledDice.apply(sum, rolls)
		end
	end
end

function DiceRoller:roll(dice, level)
	return Scheduler:enqueue(roll, self, dice, level)
end

return DiceRoller