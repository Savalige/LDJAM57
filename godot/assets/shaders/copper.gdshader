shader_type spatial;

render_mode depth_prepass_alpha;
render_mode diffuse_toon;
render_mode specular_toon;

uniform sampler2D noise : repeat_enable;
uniform float noise_shading : hint_range(0.0, 1.0) = 1.0;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 color_2 : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 noise_texture = texture(noise, UV);
	
	METALLIC = 0.7;
	ROUGHNESS = 0.9;
	ALBEDO = mix(color.rgb, color_2.rgb, noise_texture.rgb);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
