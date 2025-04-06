shader_type spatial;

render_mode depth_prepass_alpha;
render_mode diffuse_toon;
render_mode specular_toon;

uniform sampler2D noise : repeat_enable;
uniform float noise_shading : hint_range(0.0, 1.0) = 1.0;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 color : source_color = vec4(1.0, 1.0, 0.0, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 noise_texture = texture(noise, UV);
	
	ROUGHNESS = 1.0;
	ALBEDO = color.rgb * mix(vec3(1.0), noise_texture.rgb, noise_shading);
	ALPHA = color.a * step(noise_texture.r, intensity);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
