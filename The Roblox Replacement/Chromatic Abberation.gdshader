shader_type canvas_item;

uniform float alpha = 0.5;
uniform float red_offset = 0.00001;
uniform float green_offset = 0.0001;
uniform float blue_offset = -0.0004;
uniform sampler2D screen : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
//	ALBEDO =+ c.rgb;
//	ALBEDO = vec3(red, green, blue);

vec4 r = textureLod(screen, SCREEN_UV + vec2(red_offset, 0.0), 0.0);
vec4 b = textureLod(screen, SCREEN_UV + vec2(blue_offset, 0.0), 0.0);
vec4 g = textureLod(screen, SCREEN_UV + vec2(0.0, green_offset), 0.0);
COLOR = vec4(r.r, g.g, b.b, alpha);

//	COLOR.r = (SCREEN_UV.x - red_offset);
//	COLOR.b = (SCREEN_UV.x + blue_offset);
}
