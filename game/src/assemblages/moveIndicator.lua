local SheetLoader = require("src.sheetLoader")
local Crosshairs = SheetLoader:loadSheet("assets/crosshairs.png", require("assets.crosshairs"))

return function(e, position)
	return e
	:assemble(Assemblages.tile, Crosshairs.image, Crosshairs.quads.tile_1x1_valid, position, Vec2(0, 0))
end