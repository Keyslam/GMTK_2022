local QuadData = ECS.component("quadData", function(e)
	e.topLeft = {position = Vec3(), uvs = Vec2()}
	e.topRight = {position = Vec3(), uvs = Vec2()}
	e.bottomLeft = {position = Vec3(), uvs = Vec2()}
	e.bottomRight = {position = Vec3(), uvs = Vec2()}
end)