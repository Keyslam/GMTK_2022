return function(e, image, quad, position, pivot)
	local _, _, w, h = quad:getViewport()
	pivot = pivot or Vec3(w/2, h/2, 0)

	return e
	:give("transform", position, 0)
	:give("sprite", image, quad, pivot, "TILE", false, false)
end