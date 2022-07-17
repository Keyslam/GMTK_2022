local DiceResult = require("src.data.diceResults")
local D = DiceResult

local Dice = {
	{
		name = "Basic Dice",
		levels = {
			{
				{ D.value.one, D.value.two, D.value.three }
			},
			{
				{ D.value.one, D.value.two, D.value.three, D.value.four, D.value.five }
			},
			{
				{ D.value.one, D.value.two, D.value.three, D.value.four, D.value.five, D.value.six }
			},
		},
	},
	{
		name = "Even Dice",
		levels = {
			{
				{ D.value.two },
			},
			{
				{ D.value.two, D.value.four },
			},
			{
				{ D.value.two, D.value.four, D.value.six },
			},
		},
	},
	{
		name = "Uneven Dice",
		levels = {
			{
				{ D.value.one },
			},
			{
				{ D.value.one, D.value.three },
			},
			{
				{ D.value.one, D.value.three, D.value.five },
			},
		},
	},
	{
		name = "Double Dice",
		levels = {
			{
				{ D.value.one, D.value.two },
				{ D.multiplier.one, D.multiplier.two },
			},
			{
				{ D.value.one, D.value.two, D.value.three },
				{ D.multiplier.one, D.multiplier.two, D.multiplier.two },
			},
			{
				{ D.value.one, D.value.two, D.value.three, D.value.four },
				{ D.multiplier.one, D.multiplier.two, D.multiplier.two, D.multiplier.two },
			}
		},
	},
	{
		name = "High Roller Dice",
		levels = {
			{
				{ D.value.one, D.value.two, D.reroll.six },
			},
			{
				{ D.value.one, D.value.two, D.value.three, D.reroll.six},
			},
			{
				{ D.value.one, D.value.two, D.value.three, D.reroll.six, D.reroll.six }
			}
		},
	},
	{
		name = "Low Roller Dice",
		levels = {
			{
				{ D.reroll.one, D.value.two },
			},
			{
				{ D.reroll.one, D.reroll.one, D.value.two },
			},
			{
				{ D.reroll.one, D.reroll.one, D.reroll.one, D.value.two },
			},
		},
	},
}


return Dice
