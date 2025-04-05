shader_type canvas_item;

// Curvature amount
uniform float curvature : hint_range(0.0, 0.1) = 0.03;

void fragment() {
    // Get standard UV coordinates 
    vec2 uv = UV;
    
    // Convert to centered coordinates (-0.5 to 0.5)
    vec2 cc = uv - 0.5;
    
    // Calculate distance from center (squared)
    float dist = dot(cc, cc);
    
    // Apply barrel distortion
    vec2 warped_uv = uv + cc * dist * curvature;
    
    // Sample texture at the warped position
    if (warped_uv.x >= 0.0 && warped_uv.x <= 1.0 && 
        warped_uv.y >= 0.0 && warped_uv.y <= 1.0) {
        // Use modulate to preserve the original color
        COLOR = texture(TEXTURE, warped_uv);
    } else {
        // Outside the bounds of the texture, be transparent
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
}