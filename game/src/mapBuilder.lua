local SheetLoader = require("src.sheetLoader")
local Tilemap = SheetLoader:loadSheet("assets/tilemap.png", require("assets.tilemap"))

local MapBuilder = {}

function MapBuilder:build(width, height)
	local map = {}

	for x = 1, width do
		map[x] = {}

		for y = 1, height do
			if (x >= 3 and x <= 5 and y == 3) then
				map[x][y] = "WALL"
			else
				map[x][y] = "CHECKER"
			end
		end
	end

	return map
end

function MapBuilder:populateECS(map, world)
	for x = 1, #map do
		for y = 1, #map[x] do
			local kind = map[x][y]
			local quad
			local worldPosition = Vec3((x - 1) * 32, (y - 1) * 32, 0)

			if (kind == "CHECKER") then
				local isEven = (x + y % 2) % 2 == 0
				quad = isEven and Tilemap.quads.checker_red or Tilemap.quads.checker_blue
				if (x == 1 and y == 1) then quad = Tilemap.quads.checker_0_0 end

				ECS.entity(world)
				:assemble(Assemblages.tile, Tilemap.image, quad, worldPosition, Vec2(0, 0))
			end

			if (kind == "WALL") then
				ECS.entity(world)
				:assemble(Assemblages.wallTop, Tilemap.image, Tilemap.quads.wall_top_middle, worldPosition:sadd(0, 0, 32))

				ECS.entity(world)
				:assemble(Assemblages.wallSide, Tilemap.image, Tilemap.quads.wall_middle, worldPosition:sadd(0, -16, 0))
			end
		end
	end
end

return MapBuilder