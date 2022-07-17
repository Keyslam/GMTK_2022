local OccupationMap = require("src.objects.occupationMap")
local Player = require("src.objects.player")
local Floor = require("src.objects.floor")
local Wall = require("src.objects.wall")
local PawnBlack = require("src.objects.pawnBlack")
local PawnWhite = require("src.objects.pawnWhite")
local Knight = require("src.objects.knight")
local Bishop = require("src.objects.bishop")
local Rook = require("src.objects.rook")
local Queen = require("src.objects.queen")
local DiceTile = require("src.objects.diceTile")

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

function World:buildDiceTile(x, y, index)
	local quad = Tilemap.quads.floor_dice
	local worldX, worldY = Utils:tileToWorld(x, y)
	local floor = DiceTile(Vec3(worldX, worldY, 0), Tilemap.image, quad, Tilemap.quads.floor_dice_none, index)

	table.insert(self.floors, floor)
end

function World:buildWall(x, y, side, top, z)
	local sideQuad = side
	local topQuad = top

	local worldX, worldY = Utils:tileToWorld(x, y)
	local wall = Wall(Vec3(worldX, worldY, 0), Tilemap.image, sideQuad, topQuad, self.occupationMap)

	table.insert(self.walls, wall)
end

local Enemies = {
	require("src.objects.pawnBlack"),
	require("src.objects.pawnWhite"),
	require("src.objects.bishop"),
	require("src.objects.rook"),
	require("src.objects.queen"),
}

function World:spawnEnemy(position)
	local i = love.math.random(1, #Enemies)
	local enemyClass = Enemies[i]

	table.insert(self.enemies, enemyClass(Vec3(position.x, position.y, 0), self.occupationMap))
end

function World:build()
	self.player = Player(Vec3(20 * 32, 16 * 32, 0), self.occupationMap)

	-- table.insert(self.enemies, PawnBlack(Vec3(23 * 32, 16 * 32, 0), self.occupationMap))
	-- table.insert(self.enemies, PawnWhite(Vec3(25 * 32, 19 * 32, 0), self.occupationMap))
	-- table.insert(self.enemies, Knight(Vec3(19 * 32, 20 * 32, 0), self.occupationMap))
	-- table.insert(self.enemies, Rook(Vec3(20 * 32, 20 * 32, 0), self.occupationMap))
	-- table.insert(self.enemies, Bishop(Vec3(19 * 32, 21 * 32, 0), self.occupationMap))
	-- table.insert(self.enemies, Queen(Vec3(20 * 32, 21 * 32, 0), self.occupationMap))

	for x = 13, 41 do
		for y = 13, 41 do
			self:buildCheckersFloor(x, y, 0)
		end
	end

	self:buildWall(15, 14, nil, Tilemap.quads.wall_top_corner_right_big)
	for y = 12, 13 do
		self:buildWall(15, y, nil, Tilemap.quads.wall_top_right_long)
	end
	self:buildWall(15, 11, nil, Tilemap.quads.wall_top_corner_right_small)
	for x = 16, 23 do
		self:buildWall(x, 11, nil, Tilemap.quads.wall_top_middle)
	end
	self:buildWall(24, 11, nil, Tilemap.quads.wall_top_corner_left_small)
	self:buildWall(24, 12, nil, Tilemap.quads.wall_top_corner_left_big)
	for x = 25, 28 do
		self:buildWall(x, 12, nil, Tilemap.quads.wall_top_middle)
		self:buildWall(x, 11, nil, Tilemap.quads.wall_top)
	end
	self:buildWall(29, 12, nil, Tilemap.quads.wall_top_corner_right_big)
	self:buildWall(29, 11, nil, Tilemap.quads.wall_top_corner_right_small)
	for x = 30, 37 do
		self:buildWall(x, 11, nil, Tilemap.quads.wall_top_middle)
	end
	self:buildWall(38, 11, nil, Tilemap.quads.wall_top_corner_left_small)
	for y = 12, 13 do
		self:buildWall(38, y, nil, Tilemap.quads.wall_top_left_long)
	end
	self:buildWall(38, 14, nil, Tilemap.quads.wall_top_corner_left_big)
	for x = 39, 40 do
		self:buildWall(x, 14, nil, Tilemap.quads.wall_top_middle)
	end
	self:buildWall(41, 14, nil, Tilemap.quads.wall_top_corner_left_small)
	for y = 15, 31 do
		self:buildWall(41, y, nil, Tilemap.quads.wall_top_left_long)
	end
	self:buildWall(41, 32, nil, Tilemap.quads.wall_top_left_short)
	self:buildWall(41, 33, nil, Tilemap.quads.wall_top)
	for x = 39, 40 do
		self:buildWall(x, 33, Tilemap.quads.wall_middle, Tilemap.quads.wall_top)
	end
	self:buildWall(38, 33, Tilemap.quads.wall_left, Tilemap.quads.wall_top_left_long)
	self:buildWall(38, 34, nil, Tilemap.quads.wall_top_left_long)
	self:buildWall(38, 35, nil, Tilemap.quads.wall_top_left_short)
	self:buildWall(38, 36, nil, Tilemap.quads.wall_top)
	for x = 39, 41 do
		for y = 34, 36 do
			self:buildWall(x, y, nil, Tilemap.quads.wall_top)
		end
	end
	for x = 30, 37 do
		self:buildWall(x, 36, Tilemap.quads.wall_middle, Tilemap.quads.wall_top)
	end
	self:buildWall(29, 35, Tilemap.quads.wall_right, Tilemap.quads.wall_top_right_short)
	self:buildWall(29, 36, nil, Tilemap.quads.wall_top)
	for x = 25, 28 do
		self:buildWall(x, 35, Tilemap.quads.wall_middle, Tilemap.quads.wall_top)
		self:buildWall(x, 36, nil, Tilemap.quads.wall_top)
	end
	self:buildWall(24, 35, Tilemap.quads.wall_left, Tilemap.quads.wall_top_left_short)
	self:buildWall(24, 36, nil, Tilemap.quads.wall_top)
	for x = 16, 23 do
		self:buildWall(x, 36, Tilemap.quads.wall_middle, Tilemap.quads.wall_top)
	end

	self:buildWall(15, 33, Tilemap.quads.wall_right, Tilemap.quads.wall_top_right_long)
	self:buildWall(15, 34, nil, Tilemap.quads.wall_top_right_long)
	self:buildWall(15, 35, nil, Tilemap.quads.wall_top_right_short)
	self:buildWall(15, 36, nil, Tilemap.quads.wall_top)
	for x = 13, 14 do
		self:buildWall(x, 33, Tilemap.quads.wall_middle, Tilemap.quads.wall_top)
	end
	self:buildWall(12, 32, nil, Tilemap.quads.wall_top_right_short)
	self:buildWall(12, 33, nil, Tilemap.quads.wall_top)
	for y = 15, 31 do
		self:buildWall(12, y, nil, Tilemap.quads.wall_top_right_long)
	end
	for x = 12, 14 do
		for y = 34, 36 do
			self:buildWall(x, y, nil, Tilemap.quads.wall_top)
		end
	end

	self:buildWall(12, 14, nil, Tilemap.quads.wall_top_corner_right_small)
	self:buildWall(13, 14, nil, Tilemap.quads.wall_top_middle)
	self:buildWall(14, 14, nil, Tilemap.quads.wall_top_middle)

	for x = 15, 38 do
		for y = 6, 10 do
			self:buildWall(x, y, nil, Tilemap.quads.wall_top)
		end
	end

	for x = 12, 14 do
		for y = 6, 13 do
			self:buildWall(x, y, nil, Tilemap.quads.wall_top)
		end
	end

	for x = 39, 41 do
		for y = 6, 13 do
			self:buildWall(x, y, nil, Tilemap.quads.wall_top)
		end
	end

	for x = 3, 11 do
		for y = 6, 40 do
			self:buildWall(x, y, nil, Tilemap.quads.wall_top)
		end
	end

	for x = 42, 50 do
		for y = 6, 40 do
			self:buildWall(x, y, nil, Tilemap.quads.wall_top)
		end
	end

	for x = 12, 41 do
		for y = 37, 40 do
			self:buildWall(x, y, nil, Tilemap.quads.wall_top)
		end
	end

	self:buildWall(17, 23, Tilemap.quads.wall_left, Tilemap.quads.wall_top_left_long)
	self:buildWall(18, 23, Tilemap.quads.wall_right, Tilemap.quads.wall_top_right_long)
	self:buildWall(17, 24, nil, Tilemap.quads.wall_top_corner_left_big)
	self:buildWall(18, 24, nil, Tilemap.quads.wall_top_corner_right_big)

	self:buildWall(35, 23, Tilemap.quads.wall_left, Tilemap.quads.wall_top_left_long)
	self:buildWall(36, 23, Tilemap.quads.wall_right, Tilemap.quads.wall_top_right_long)
	self:buildWall(35, 24, nil, Tilemap.quads.wall_top_corner_left_big)
	self:buildWall(36, 24, nil, Tilemap.quads.wall_top_corner_right_big)

	self:buildWall(25, 20, Tilemap.quads.wall_left, Tilemap.quads.wall_top_left_long)
	self:buildWall(26, 20, Tilemap.quads.wall_middle, Tilemap.quads.wall_top)
	self:buildWall(27, 20, Tilemap.quads.wall_middle, Tilemap.quads.wall_top)
	self:buildWall(28, 20, Tilemap.quads.wall_right, Tilemap.quads.wall_top_right_long)

	self:buildWall(25, 21, nil, Tilemap.quads.wall_top_left_short)
	self:buildWall(26, 21, nil, Tilemap.quads.wall_top)
	self:buildWall(27, 21, nil, Tilemap.quads.wall_top)
	self:buildWall(28, 21, nil, Tilemap.quads.wall_top_right_short)
	self:buildWall(24, 22, Tilemap.quads.wall_middle, Tilemap.quads.wall_top)
	self:buildWall(23, 22, Tilemap.quads.wall_left, Tilemap.quads.wall_top_left_long)
	self:buildWall(29, 22, Tilemap.quads.wall_middle, Tilemap.quads.wall_top)
	self:buildWall(30, 22, Tilemap.quads.wall_right, Tilemap.quads.wall_top_right_long)

	self:buildWall(23, 23, nil, Tilemap.quads.wall_top_left_long)
	self:buildWall(30, 23, nil, Tilemap.quads.wall_top_right_long)
	self:buildWall(23, 24, nil, Tilemap.quads.wall_top_left_long)
	self:buildWall(30, 24, nil, Tilemap.quads.wall_top_right_long)
	self:buildWall(23, 25, nil, Tilemap.quads.wall_top_corner_left_big)
	self:buildWall(30, 25, nil, Tilemap.quads.wall_top_corner_right_big)

	self:buildWall(24, 25, nil, Tilemap.quads.wall_top_middle)
	self:buildWall(29, 25, nil, Tilemap.quads.wall_top_middle)

	self:buildWall(25, 25, nil, Tilemap.quads.wall_top_corner_left_small)
	self:buildWall(28, 25, nil, Tilemap.quads.wall_top_corner_right_small)

	self:buildWall(25, 26, nil, Tilemap.quads.wall_top_left_long)
	self:buildWall(28, 26, nil, Tilemap.quads.wall_top_right_long)

	self:buildWall(25, 27, nil, Tilemap.quads.wall_top_corner_left_big)
	self:buildWall(28, 27, nil, Tilemap.quads.wall_top_corner_right_big)

	self:buildWall(26, 27, nil, Tilemap.quads.wall_top_middle)
	self:buildWall(27, 27, nil, Tilemap.quads.wall_top_middle)

	self:buildWall(26, 26, nil, Tilemap.quads.wall_top)
	self:buildWall(27, 26, nil, Tilemap.quads.wall_top)
	self:buildWall(26, 25, nil, Tilemap.quads.wall_top)
	self:buildWall(27, 25, nil, Tilemap.quads.wall_top)

	self:buildWall(24, 24, nil, Tilemap.quads.wall_top)
	self:buildWall(25, 24, nil, Tilemap.quads.wall_top)
	self:buildWall(26, 24, nil, Tilemap.quads.wall_top)
	self:buildWall(27, 24, nil, Tilemap.quads.wall_top)
	self:buildWall(28, 24, nil, Tilemap.quads.wall_top)
	self:buildWall(29, 24, nil, Tilemap.quads.wall_top)

	self:buildWall(24, 23, nil, Tilemap.quads.wall_top)
	self:buildWall(25, 23, nil, Tilemap.quads.wall_top)
	self:buildWall(26, 23, nil, Tilemap.quads.wall_top)
	self:buildWall(27, 23, nil, Tilemap.quads.wall_top)
	self:buildWall(28, 23, nil, Tilemap.quads.wall_top)
	self:buildWall(29, 23, nil, Tilemap.quads.wall_top)

	self:buildWall(25, 22, nil, Tilemap.quads.wall_top)
	self:buildWall(26, 22, nil, Tilemap.quads.wall_top)
	self:buildWall(27, 22, nil, Tilemap.quads.wall_top)
	self:buildWall(28, 22, nil, Tilemap.quads.wall_top)

	-- self:buildWall(16, 32, nil, Tilemap.quads.wall_)


	self:buildDiceTile(16, 16, 1)
	self:buildDiceTile(37, 16, 2)
	self:buildDiceTile(16, 32, 3)
	self:buildDiceTile(37, 32, 4)


	-- for x = 0, width - 1 do
	-- 	for y = 0, height - 1 do
	-- 		if (x >= 5 and x <= 8 and y == 3) then
	-- 			self:buildWall(x, y, 0)
	-- 		else
	-- 			self:buildCheckersFloor(x, y, 0)
	-- 		end
	-- 	end
	-- end
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