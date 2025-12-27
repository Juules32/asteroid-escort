//Shader insprired from https://godotshaders.com/shader/color-replacer/
shader_type canvas_item;

uniform vec4 color1: source_color;
uniform vec4 color1_replacement: source_color;

uniform vec4 color2: source_color;
uniform vec4 color2_replacement: source_color;

uniform vec4 color3: source_color;
uniform vec4 color3_replacement: source_color;

uniform vec4 color4: source_color;
uniform vec4 color4_replacement: source_color;

uniform vec4 color5: source_color;
uniform vec4 color5_replacement: source_color;

uniform vec4 color6: source_color;
uniform vec4 color6_replacement: source_color;

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 tex_color = texture(TEXTURE, UV);
	
	
	if (tex_color.a > 0.0) {
		float dist1 = length(tex_color.rgb - color1.rgb);
		float dist2 = length(tex_color.rgb - color2.rgb);
		float dist3 = length(tex_color.rgb - color3.rgb);
		float dist4 = length(tex_color.rgb - color4.rgb);
		float dist5 = length(tex_color.rgb - color5.rgb);
		float dist6 = length(tex_color.rgb - color6.rgb);
		
		if (dist1 == 0.0) {
			tex_color = color1_replacement;
		} else if (dist2 == 0.0) {
			tex_color = color2_replacement;
		} else if (dist3 == 0.0) {
			tex_color = color3_replacement;
		} else if (dist4 == 0.0) {
			tex_color = color4_replacement;
		} else if (dist5 == 0.0) {
			tex_color = color5_replacement;
		} else if (dist6 == 0.0) {
			tex_color = color6_replacement;
		}
		
		tex_color.a = color1_replacement.a;
		
		COLOR = tex_color;
	}
}