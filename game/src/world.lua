local OccupationMap = require("src.objects.occupationMap")
local Player = require("src.objects.player")
local Floor = require("src.objects.floor")
local Wall = require("src.objects.wall")
local PawnBlack = require("src.objects.pawnBlack")
local PawnWhite = require("src.objects.pawnWhite")

local Tilemap = SheetLoader:loadSheet("assets/tilemap.png", require("assets.tilemap"))

local World = {
	player = nil,
	floors = {},
	walls = {},
	enemies = {},

	occupationMap = OccupationMap(),
}

function World:buildCheckersFloor(x, y, z)
	local isEven = (x + y % 2) % 2 == 0
	local quad = isEven and Tilemap.quads.checker_red or Tilemap.quads.checker_blue
	if (x == 0 and y == 0) then quad = Tilemap.quads.checker_0_0 end

	local worldX, worldY = Utils:tileToWorld(x, y)
	local floor = Floor(Vec3(worldX, worldY, z), Tilemap.image, quad, self.occupationMap)

	table.insert(self.floors, floor)
end

function World:buildWall(x, y, z)
	local sideQuad = Tilemap.quads.wall_left
	local topQuad = Tilemap.quads.wall_top_left

	local worldX, worldY = Utils:tileToWorld(x, y)
	local wall = Wall(Vec3(worldX, worldY, z), Tilemap.image, sideQuad, topQuad, self.occupationMap)

	table.insert(self.walls, wall)
end

function World:build(width, height)
	self.player = Player(Vec3(0, 0, 0), self.occupationMap)

	table.insert(self.enemies, PawnBlack(Vec3(1 * 32, 0 * 32, 0), self.occupationMap))
	table.insert(self.enemies, PawnWhite(Vec3(3 * 32, 1 * 32, 0), self.occupationMap))

	for x = 0, width - 1 do
		for y = 0, height - 1 do
			if (x >= 5 and x <= 8 and y == 3) then
				self:buildWall(x, y, 0)
			else
				self:buildCheckersFloor(x, y, 0)
			end
		end
	end
end

function World:update(dt)
	self.player:update(dt)

	for i = #self.enemies, 1, -1 do
		if (self.enemies[i].dead) then
			table.remove(self.enemies, i)
		end
	end

	for _, enemy in ipairs(self.enemies) do
		enemy:update(dt)
	end
end

function World:draw()
	self.player:draw()

	for _, floor in ipairs(self.floors) do
		floor:draw()
	end

	for _, wall in ipairs(self.walls) do
		wall:draw()
	end

	for _, enemy in ipairs(self.enemies) do
		enemy:draw()
	end
end

function World:keypressed(key)
	self.player:keypressed(key)
end

return World