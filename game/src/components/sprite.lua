local Sprite = ECS.component("sprite", function(e, image, quad, kind, flipX, flipY)
	e.image = image
	e.quad = quad
	e.kind = kind
	e.flipX = flipX
	e.flipY = flipY
end)