local OccupationMap = Class("OccupationMap")

function OccupationMap:initialize()
	self.objects = {}
	self.map = {}
end

function OccupationMap:add(object, position)
	local tileX, tileY = position.x, position.y

	if (not self.map[tileX]) then
		self.map[tileX] = {}
	end
	self.map[tileX][tileY] = object

	self.objects[object] = position:copy()
end

function OccupationMap:update(object, position)
	local oldPosition = self.objects[object]
	local oldX, oldY = oldPosition.x, oldPosition.y
	local x, y = position.x, position.y

	self.map[oldX][oldY] = nil

	if (not self.map[x]) then
		self.map[x] = {}
	end
	self.map[x][y] = object

	self.objects[object]:sset(position.x, position.y)
end

function OccupationMap:remove(object)
	local oldPosition = self.objects[object]
	local oldX, oldY = oldPosition.x, oldPosition.y

	if (not self.map[oldX]) then
		self.map[oldX] = {}
	end
	self.map[oldX][oldY] = nil

	self.objects[object] = nil
end

function OccupationMap:at(position)
	return self.map[position.x] and self.map[position.x][position.y]
end

function OccupationMap:atOfType(position, type)
	return self.map[position.x] and self.map[position.x][position.y] and self.map[position.x][position.y][type]
end

return OccupationMap