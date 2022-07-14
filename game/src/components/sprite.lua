local Sprite = ECS.component("sprite", function(e, image, quad, origin, pivot, kind, flipX, flipY)
	e.image = image
	e.quad = quad

	e.origin = origin
	e.pivot = pivot

	e.kind = kind

	e.flipX = flipX
	e.flipY = flipY
end)