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

function Utils:lerp(v0, v1, t)
    return v0*(1-t)+v1*t
end

return Utils