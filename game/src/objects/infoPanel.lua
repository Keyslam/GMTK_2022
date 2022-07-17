local InfoPanelSprite = love.graphics.newImage("assets/infoPanel.png")
local Font = love.graphics.newFont("assets/FutilePro.ttf", 16)

local Entity = require("src.objects.entity")

local DicePanel = Class("DicePanel", Entity)

function DicePanel:initialize()
	local w, h = InfoPanelSprite:getDimensions()
	self.shownPosition = Vec2(GameWidth / 2, 0 + h)
	self.hiddenPosition = Vec2(GameWidth / 2, 0 - h)

	self.position = self.hiddenPosition:copy()

	self.didCollect = false
	self.name = ""
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

function DicePanel:show(collect, name)
	self.didCollect = collect
	self.name = name

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

function DicePanel:draw()
	love.graphics.draw(InfoPanelSprite, self.position.x, self.position.y, 0, 1, 1, 244/2, 64/2)

	love.graphics.push("all")
		love.graphics.setFont(Font)
		love.graphics.setColor(34/255, 32/255, 52/255)
		if (self.didCollect) then
			love.graphics.printf("Collected", self.position.x - 90, self.position.y - 32 + 10, 180, "center")
		else
			love.graphics.printf("Upgraded", self.position.x - 90, self.position.y - 32 + 10, 180, "center")
		end
		love.graphics.printf("\""..self.name.."\"", self.position.x - 90, self.position.y - 32 + 10 + 20, 180, "center")
	love.graphics.pop()
end

return DicePanel