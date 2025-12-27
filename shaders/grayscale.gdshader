shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 color = texture(screen_texture, UV);
	float color_mix = (color.r + color.g + color.b) / 3.0;
	COLOR = vec4(color_mix, color_mix, color_mix, 1.0);
}