shader_type spatial;
render_mode unshaded, shadows_disabled;
uniform sampler2D back_tex : repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    vec2 uv = SCREEN_UV + TIME * vec2(0.05, 0.06);
	vec2 uv2 = SCREEN_UV + TIME * vec2(-0.05, 0.04);

    // Simple animated distortion
    //uv.x += sin(uv.y * 40.0 + TIME * 3.0) * 0.1;
	//ALPHA = 0.99;
	ALBEDO = mix(texture(back_tex, uv).rgb, texture(back_tex, uv2).rgb, texture(back_tex, uv).rgb);
}