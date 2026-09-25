shader_type canvas_item;

uniform int y_res = 240;
uniform float fisheye = 0.1;
uniform float color_depth = 8.0;
uniform bool active = false;

vec2 curve(vec2 uv) {

	uv = (uv - 0.5) * 2.0;
	uv *= 1.1;
	uv *= 1.0 + uv.x * uv.x * uv.x * uv.x * uv.y * uv.y * uv.y * uv.y * fisheye;
	uv  = (uv / 2.0) + 0.5;
	uv =  uv * 0.92 + 0.04;

	return uv;
}
void fragment() {
	if(active){
		
		vec2 resolution = vec2(float(y_res) * TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x, float(y_res));
		vec2 uv = UV;//curve(UV);
		vec2 pixel = floor(uv * resolution);
		uv = pixel / resolution;
	    
		vec3 col;
		
		if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
			col = vec3(0.0);
		} else {
			col = texture(TEXTURE, uv).xyz;
		}

		// quantize channels with dithering (only half of all pixels round to nearest, other half round down)
		col *= color_depth;
		if (floor(mod(pixel.x, 2.0)) == floor(mod(pixel.y, 2.0))) {

			if (mod(col.r, 1.0) > 0.5) {
				col.r = ceil(col.r);
			} else {
				col.r = floor(col.r);
			}

			if (mod(col.g, 1.0) > 0.5) {
				col.g = ceil(col.g);
			} else {
				col.g = floor(col.g);
			}

			if (mod(col.b, 1.0) > 0.5) {
				col.b = ceil(col.b);
			} else {
				col.b = floor(col.b);
			}
		} else {
			col = floor(col);
		}
		col /= color_depth;

	    COLOR = vec4(col, 1.0);
	}
}