local DiceResult = require("src.data.diceResults")
local D = DiceResult

local Dice = {
	{
		name = "Basic Dice",
		levels = {
			{
				{ D.value.one, D.value.two, D.value.three, D.value.four, D.value.five, D.value.six }
			},
			{
				{ D.value.two, D.value.three, D.value.five, D.value.five, D.value.six, D.value.six, }
			},
			{
				{ D.value.five, D.value.five, D.value.five, D.value.six, D.value.six, D.value.six }
			},
		},
	},
	{
		name = "Even Dice",
		levels = {
			{
				{ D.value.two, D.value.four },
			},
			{
				{ D.value.two, D.value.four, D.value.six },
			},
			{
				{ D.value.two, D.value.four, D.value.six, D.value.eight },
			},
		},
	},
	{
		name = "Uneven Dice",
		levels = {
			{
				{ D.value.one, D.value.three },
			},
			{
				{ D.value.one, D.value.three, D.value.five },
			},
			{
				{ D.value.one, D.value.three, D.value.seven },
			},
		},
	},
	{
		name = "Double Dice",
		levels = {
			{
				{ D.value.three, D.value.four },
				{ D.multiplier.one, D.multiplier.two },
			},
			{
				{ D.value.three, D.value.four, D.value.five },
				{ D.multiplier.one, D.multiplier.two, D.multiplier.two },
			},
			{
				{ D.value.three, D.value.four, D.value.five, D.value.six },
				{ D.multiplier.one, D.multiplier.two, D.multiplier.two, D.multiplier.two },
			}
		},
	},
	{
		name = "High Roller Dice",
		levels = {
			{
				{ D.value.three, D.value.four, D.reroll.six },
			},
			{
				{ D.value.three, D.value.four, D.value.five, D.reroll.six},
			},
			{
				{ D.value.three, D.value.four, D.value.five, D.reroll.six, D.reroll.six }
			}
		},
	},
	{
		name = "Low Roller Dice",
		levels = {
			{
				{ D.reroll.one, D.reroll.one, D.reroll.one, D.value.two },
			},
			{
				{ D.reroll.one, D.reroll.one, D.reroll.one, D.reroll.one, D.value.two },
			},
			{
				{ D.reroll.one, D.reroll.one, D.reroll.one, D.reroll.one, D.reroll.one, D.value.two },
			},
		},
	},
}


return Dice
