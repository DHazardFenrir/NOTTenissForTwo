shader_type canvas_item;

uniform float power : hint_range(0.0, 1.0) = 0.0;
uniform vec3 spot_color : source_color = vec3(0.8, 0.2, 1.0);
uniform vec3 base_color : source_color = vec3(0.12, 0.02, 0.22);
uniform vec2 spot_scale = vec2(3.0, 12.0);
uniform float speed = 1.5;
uniform float shimmer_strength : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec2 p = UV * spot_scale;
    float t = TIME * speed;

    // Wobbly plasma field
    float v = sin(p.x + t)
            + sin(p.y * 1.3 - t * 0.8)
            + sin((p.x + p.y) * 0.7 + t * 1.2)
            + sin(length(p - spot_scale * 0.5) * 1.5 - t * 2.0);

    // --- Background: dark purple that shimmers ---
    // Gentle light and shadow that follows the plasma field
    vec3 col = base_color * (0.7 + 0.3 * (v * 0.25 + 0.5));

    // Fine sparkle that flickers
    float sparkle = sin(p.x * 23.0 + TIME * 7.0) * sin(p.y * 17.0 - TIME * 5.0);
    sparkle = pow(max(sparkle, 0.0), 16.0);
    col += spot_color * sparkle * 0.6 * shimmer_strength;

    // --- Spots: bright purple with a soft glow and hot centers ---
    float pulse = 0.85 + 0.15 * sin(TIME * 4.0);
    float halo  = smoothstep(0.6, 1.4, v);   // soft glow around each spot
    float spots = smoothstep(1.2, 1.6, v);   // the spot itself
    float core  = smoothstep(2.0, 2.6, v);   // brightest center

    col += spot_color * halo * 0.35 * pulse;
    col = mix(col, spot_color * 1.3 * pulse, spots);
    col = mix(col, vec3(1.0, 0.75, 1.0), core * 0.7);

    COLOR.rgb = mix(COLOR.rgb, col, power);
}