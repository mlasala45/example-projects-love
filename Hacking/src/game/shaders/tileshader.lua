return [[uniform Image tex;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	//texture_coords = screen_coords;
	vec4 pixel = Texel(tex, texture_coords);
	vec4 pixel2 = Texel(texture, texture_coords);
	vec4 ret = vec4(pixel2.r, pixel2.g, 0.0, 1.0);
	ret.a = pixel2.a;
	return ret;
}]]