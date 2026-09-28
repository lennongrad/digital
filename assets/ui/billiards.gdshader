shader_type canvas_item;
uniform sampler2D noise_tex : repeat_enable;
uniform sampler2D back_tex : repeat_enable;

void fragment() {
	float res = 50.0 * (1.25 + cos(TIME * 0.2) * 0.5);
	float x_scale = 2.0;//TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x;
	vec2 coords =  vec2(floor(UV.x * res * x_scale), floor(UV.y * res));
	vec2 uv = coords / vec2(res * x_scale, res);
	
	vec4 ns = texture(noise_tex, uv + TIME * vec2(0.1, 0.05));
	vec3 col = texture(back_tex, UV).rgb; 
	if(mod(coords.x + coords.y, 2.0) >= 1.0){
		col *= pow(ns.x + 0.1, 0.25);
	}
	
	//vec3 col = ns.rgb;
    COLOR = vec4(col, 1.0);
}
