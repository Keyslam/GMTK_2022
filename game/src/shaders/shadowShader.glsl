uniform mat4 view_matrix;
uniform mat4 projection_matrix;

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position) {
	mat4 lightSpaceMatrix = projection_matrix * view_matrix;
	return lightSpaceMatrix * vec4(vertex_position.rgb, 1.0);
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec4 pixel = Texel(texture, texture_coords);
	if (pixel.a == 0.0f) {
		discard;
	}
	return color * pixel;
}
#endif
