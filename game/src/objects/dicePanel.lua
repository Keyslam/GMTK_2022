local DicePanelSheet = SheetLoader:loadSheet("assets/dicePanel.png", require("assets.dicePanel"))
local Dice = SheetLoader:loadSheet("assets/dice.png", require("assets.dice"))
local Font = love.graphics.newFont("assets/FutilePro.ttf", 16)

local swipes = {
	love.audio.newSource("assets/sfx/swipe-bounce-1.wav", "static"),
	love.audio.newSource("assets/sfx/swipe-bounce-2.wav", "static"),
	love.audio.newSource("assets/sfx/swipe-bounce-3.wav", "static"),
	love.audio.newSource("assets/sfx/swipe-bounce-4.wav", "static"),
}

local Entity = require("src.objects.entity")

local DicePanel = Class("DicePanel", Entity)

function DicePanel:initialize()
	local _, _, w, h = DicePanelSheet.quads.sprite:getViewport()
	self.shownPosition = Vec2(GameWidth / 2, GameHeight - h)
	self.hiddenPosition = Vec2(GameWidth / 2, GameHeight + h)
	self.leftPosition = Vec2(0 - w - 40, GameHeight - h)
	self.rightPosition = Vec2(GameWidth + w + 40, GameHeight - h)

	self.leftArrowOffset = Vec2(0 - w/2 - 15, 0)
	self.rightArrowOffset = Vec2(0 + w/2 + 15, 0)

	self.position = self.hiddenPosition:copy()

	self.diceKind = nil
	self.diceSets = nil
end

local function show(self)
	local done = false
	Flux.to(self.position, 0.4, self.shownPosition)
	:ease("quintout")
	:oncomplete(function()
		done = true
	end)

	while (not done) do
		coroutine.yield()
	end
end

function DicePanel:show(diceKind, diceSets)
	self.diceKind = diceKind
	self.diceSets = diceSets

	return Scheduler:enqueue(show, self)
end

local function hide(self)
	local done = false
	Flux.to(self.position, 0.4, self.hiddenPosition)
	:ease("quintout")
	:oncomplete(function()
		done = true
	end)

	while (not done) do
		coroutine.yield()
	end
end

function DicePanel:hide()
	return Scheduler:enqueue(hide, self)
end

local function change(self, exit, entry, diceKind, diceSets)
	local i = love.math.random(1, #swipes)
	swipes[i]:setPitch(love.math.random(95, 105)/100)
	swipes[i]:play()

	do
		local done = false
		Flux.to(self.position, 0.2, exit)
		:ease("cubicin")
		:oncomplete(function()
			done = true
		end)

		while (not done) do
			coroutine.yield()
		end
	end

	self.diceKind = diceKind
	self.diceSets = diceSets
	self.position:vset(entry)

	do
		local done = false
		Flux.to(self.position, 0.2, self.shownPosition)
		:ease("quintout")
		:oncomplete(function()
			done = true
		end)

		while (not done) do
			coroutine.yield()
		end
	end
end

function DicePanel:changeLeft(diceKind, diceSets)
	return Scheduler:enqueue(change, self, self.leftPosition, self.rightPosition, diceKind, diceSets)
end

function DicePanel:changeRight(diceKind, diceSets)
	return Scheduler:enqueue(change, self, self.rightPosition, self.leftPosition, diceKind, diceSets)
end

function DicePanel:draw()
	love.graphics.draw(DicePanelSheet.image, DicePanelSheet.quads.sprite, self.position.x, self.position.y, 0, 1, 1, 90, 32)


	do
		local x = math.floor((self.position.x + self.leftArrowOffset.x + math.sin(love.timer.getTime() * 3) * 3) + 0.5)
		local y = self.position.y + self.leftArrowOffset.y
		love.graphics.draw(DicePanelSheet.image, DicePanelSheet.quads.arrow_left, x, y, 0, 1, 1, 5, 10)
	end

	do
		local x = math.floor((self.position.x + self.rightArrowOffset.x + math.sin((love.timer.getTime() + math.pi) * 3) * 3) + 0.5)
		local y = self.position.y + self.rightArrowOffset.y
		love.graphics.draw(DicePanelSheet.image, DicePanelSheet.quads.arrow_right, x, y, 0, 1, 1, 5, 10)
	end


	if (self.diceKind) then
		love.graphics.push("all")
		love.graphics.setFont(Font)
		love.graphics.setColor(34/255, 32/255, 52/255)
		love.graphics.printf(self.diceKind.name, self.position.x - 90, self.position.y - 32 + 10, 180, "center")
		love.graphics.pop()

		local setsCount = 0
		local diceAmount = 0
		for _, set in ipairs(self.diceSets) do
			diceAmount = diceAmount + #set
			setsCount = setsCount + 1
		end

		local requiredSpace = diceAmount * 16 + (diceAmount - 1) * 4 + (setsCount - 1) * 4
		local x = self.position.x - requiredSpace/2

		for i, set in ipairs(self.diceSets) do
			if (i > 1) then
				love.graphics.draw(Dice.image, Dice.quads.divider, x - 1, self.position.y)
				x = x + 4
			end

			for _, diceSetElement in ipairs(set) do
				love.graphics.draw(Dice.image, diceSetElement.quad, x, self.position.y)
				x = x + 20
			end
		end
	end
end

return DicePanel