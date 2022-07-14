return function(e, image, quad, position, origin, pivot, flipX, flipY)
	local _, _, w, h = quad:getViewport()
	origin = origin or Vec3(w/2, 0, 0)
	pivot = pivot or Vec3(w/2, h/2, 0)

	return e
	:give("transform", position, 0)
	:give("sprite", image, quad, origin, pivot, "PROP", flipX, flipY)
end