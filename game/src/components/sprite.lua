local Sprite = ECS.component("sprite", function(e, image, quad, pivot, height, flipX, flipY)
	local qx, qy, qw, qh = quad:getViewport()
	local sw, sh = quad:getTextureDimensions()

	e.image = image
	e.quad = quad
	e.pivot = pivot or Vec2(qw/2, qh/2)
	e.height = height or qh

	e.flipX = flipX
	e.flipY = flipY

	e.qx, e.qy, e.qw, e.qh = qx, qy, qw, qh
	e.sw, e.sh = sw, sh
end)