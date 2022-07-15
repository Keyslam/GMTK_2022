local Sprite = ECS.component("sprite", function(e, image, quad, pivot, kind, flipX, flipY)
	local ix, iy, iw, ih = quad:getViewport()
	local sw, sh = quad:getTextureDimensions()

	e.image = image
	e.quad = quad

	e.pivotFlat = Vec3(pivot.x, pivot.y, 0)
	e.pivotDiagonal = Vec3(pivot.x, pivot.y, pivot.y/(ih/2) * ih/2)

	e.kind = kind

	e.flipX = flipX
	e.flipY = flipY
end)

local out = Vec3(0, 0, 0)
function Sprite:spriteToWorldSprite(p)
	out:sset(p.x, p.y, 0)

	local ix, iy, iw, ih = self.quad:getViewport()
	local sw, sh = self.quad:getTextureDimensions()

	if (self.kind == "TILE") then
		out:vaddi(self.pivotFlat)
	end

	if (self.kind == "PROP") then
		out:vaddi(self.pivotDiagonal)
		out.z = out.y / (ih / 2) * ih / 2
	end

	return out
end