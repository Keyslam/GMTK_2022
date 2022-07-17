local Utils = {}

function Utils:worldToTile(x, y)
	x = math.floor((x + 16) / 32)
	y = math.floor((y + 16) / 32)

	return x, y
end

function Utils:tileToWorld(x, y)
	x = x * 32
	y = y * 32

	return x, y
end

function Utils:vWorldToTile(v)
	local out = Vec2(0, 0)
	out.x, out.y = self:worldToTile(v.x, v.y)

	return out
end

function Utils:vTileToWorld(v)
	local out = Vec2(0, 0)
	out.x, out.y = self:vTileToWorld(v.x, v.y)

	return out
end

function Utils:wrap(x, x_min, x_max)
	x_max = x_max + 1
	return (((x - x_min) % (x_max - x_min)) + (x_max - x_min)) % (x_max - x_min) + x_min;
 end

function Utils:lerp(v0, v1, t)
    return v0*(1-t)+v1*t
end

return Utils