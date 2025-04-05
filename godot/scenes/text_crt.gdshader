shader_type canvas_item;

// Only the curvature parameter
uniform float curvature : hint_range(0.0, 0.1) = 0.03;

void fragment() {
    // Get the coordinates
    vec2 uv = UV;
    
    // Convert to center coordinates
    vec2 cc = uv - 0.5;
    
    // Distance from center
    float dist = dot(cc, cc);
    
    // Apply only curvature, exactly the same as in your original shader
    vec2 warped_uv = uv + cc * dist * curvature;
    
    // Sample the texture at the warped position
    if (warped_uv.x >= 0.0 && warped_uv.x <= 1.0 && 
        warped_uv.y >= 0.0 && warped_uv.y <= 1.0) {
        COLOR = texture(TEXTURE, warped_uv);
    } else {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
}