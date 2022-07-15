uniform mat4 view_matrix;
uniform mat4 projection_matrix;

uniform mat4 lightSpace_view_matrix;
uniform mat4 lightSpace_projection_matrix;

uniform sampler2D shadowmap;

varying vec4 FragPosLightSpace;

#ifdef VERTEX

vec4 position(mat4 transform_projection, vec4 vertex_position) {
	mat4 lightSpaceMatrix = lightSpace_projection_matrix * lightSpace_view_matrix;

	vec4 fragPos = vec4(vertex_position.xyz, 1.0f);
	FragPosLightSpace = lightSpaceMatrix * vec4(fragPos.xyz, 1.0f);
	return projection_matrix * view_matrix * vec4(fragPos.xyz, 1.0f);
}
#endif

#ifdef PIXEL

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec3 projCoords = FragPosLightSpace.xyz / FragPosLightSpace.w;
	projCoords = projCoords * 0.5 + 0.5; 
	float closestDepth = Texel(shadowmap, projCoords.xy).r;
	float currentDepth = projCoords.z;

	vec4 pixel = Texel(texture, texture_coords);
	
	if (pixel.a == 0.0f)
		discard;

	if (currentDepth - 0.005 > closestDepth) {
		float a = pixel.a;
		pixel *= 0.7f;
		pixel.a = a;
	}


	return color * pixel;
}
#endif
