local SheetLoader = {}

function SheetLoader:loadSheet(imageSource, data)
	local image = love.graphics.newImage(imageSource)
	local quads = {}

	local sw, sh = image:getDimensions()
	for name, info in pairs(data) do
		local quad = love.graphics.newQuad(info.x, info.y, info.w, info.h, sw, sh)
		quads[name] = quad
	end

	return {
		image = image,
		quads = quads,
	}
end

return SheetLoader