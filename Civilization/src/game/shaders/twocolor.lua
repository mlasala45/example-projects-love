return [[uniform vec4 fg_color = vec4(0.5, 1.0, 0.0, 1.0);
uniform vec4 bg_color = vec4(0.5, 0.0, 1.0, 1.0);

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec4 pixel = Texel(texture, texture_coords);
	if(pixel.a == 0.0) return vec4(0.0, 0.0, 0.0, 0.0);
	vec4 fg = fg_color*pixel.r;
	vec4 bg = bg_color*pixel.b;
	vec4 ret = (fg + bg) * color;
	ret.a = pixel.a;
	return ret;
}]]