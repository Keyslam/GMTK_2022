local Dice = SheetLoader:loadSheet("assets/dice.png", require("assets.dice"))

local DiceResult = {
	value = {
		zero = {
			quad = Dice.quads.value_zero,
			value = 0,
			rerolls = 0,
			multiplier = 1,
		},
		one = {
			quad = Dice.quads.value_one,
			value = 1,
			rerolls = 0,
			multiplier = 1,
		},
		two = {
			quad = Dice.quads.value_two,
			value = 2,
			rerolls = 0,
			multiplier = 1,
		},
		three = {
			quad = Dice.quads.value_three,
			value = 3,
			rerolls = 0,
			multiplier = 1,
		},
		four = {
			quad = Dice.quads.value_four,
			value = 4,
			rerolls = 0,
			multiplier = 1,
		},
		five = {
			quad = Dice.quads.value_five,
			value = 5,
			rerolls = 0,
			multiplier = 1,
		},
		six = {
			quad = Dice.quads.value_six,
			value = 6,
			rerolls = 0,
			multiplier = 1,
		},
		seven = {
			quad = Dice.quads.value_seven,
			value = 7,
			rerolls = 0,
			multiplier = 1,
		},
		eight = {
			quad = Dice.quads.value_eight,
			value = 8,
			rerolls = 0,
			multiplier = 1,
		},
		nine = {
			quad = Dice.quads.value_nine,
			value = 9,
			rerolls = 0,
			multiplier = 1,
		},
	},
	multiplier = {
		one = {
			quad = Dice.quads.multiplier_one,
			value = 0,
			rerolls = 0,
			multiplier = 1,
		},
		two = {
			quad = Dice.quads.multiplier_two,
			value = 0,
			rerolls = 0,
			multiplier = 2,
		}
	},
	reroll = {
		one = {
			quad = Dice.quads.reroll_one,
			value = 1,
			rerolls = 1,
			multiplier = 1,
		},
		six = {
			quad = Dice.quads.reroll_six,
			value = 6,
			rerolls = 1,
			multiplier = 1,
		}
	}
}

return DiceResult