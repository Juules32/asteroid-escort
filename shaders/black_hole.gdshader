shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0, 0.001) = 0.05;
uniform float swirl_strength : hint_range(0.0, 10.0, 0.01) = 2.0;
uniform float spin_speed : hint_range(-10.0, 10.0, 0.01) = 1.0;
uniform float black_radius : hint_range(0.0, 1.0, 0.001) = 0.3;
uniform float chroma_strength : hint_range(0.0, 0.1, 0.001) = 0.01;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    vec2 diff = center - vec2(UV.x, 1.0 - UV.y);
    float d = length(diff) * 2.0;
    vec2 dir = normalize(diff);

    // Smooth falloff for effect
    float f = clamp(1.0 - d, 0.0, 1.0);
    float shelf = smoothstep(0.0, 1.0, f);

    // Radial pull
    float displacement = strength / (d*d + 0.01);

    // Swirl + spin
    float angle = swirl_strength * displacement + TIME * spin_speed;
    float s = sin(angle);
    float c = cos(angle);
    vec2 rotated_dir = vec2(dir.x * c - dir.y * s, dir.x * s + dir.y * c);

    // Apply radial pull and swirl
    vec2 uv = SCREEN_UV + rotated_dir * (displacement * shelf);

    // Chromatic aberration offsets
    float chroma = chroma_strength * (1.0 - d);
    vec2 uv_r = uv + vec2(chroma, 0.0);
    vec2 uv_g = uv;
    vec2 uv_b = uv - vec2(chroma, 0.0);

    // fixed high scale (no blur)
    const float PIXEL_SCALE = 10000.0;
    uv_r = floor(uv_r * PIXEL_SCALE) / PIXEL_SCALE;
    uv_g = floor(uv_g * PIXEL_SCALE) / PIXEL_SCALE;
    uv_b = floor(uv_b * PIXEL_SCALE) / PIXEL_SCALE;

    // Chromatic abberation
    vec3 col;
    col.r = texture(SCREEN_TEXTURE, uv_r).r;
    col.g = texture(SCREEN_TEXTURE, uv_g).g;
    col.b = texture(SCREEN_TEXTURE, uv_b).b;

    // Black hole core
    COLOR.rgb = mix(col, vec3(0.0), smoothstep(1.0 - black_radius-0.01, 1.0 - black_radius+0.01, f));
}
