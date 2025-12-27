shader_type canvas_item;

uniform sampler2D mask;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	float mask_a = texture(mask, UV).r + texture(mask, vec2(1.0 - UV.x, UV.y)).r;

	base.a = clamp(mask_a, 0.0, 1.0);
	COLOR = base;
}