shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Scanline properties
uniform float line_density : hint_range(10.0, 300.0) = 100.0;
uniform float line_sharpness : hint_range(0.0, 10.0) = 2.0; // Reduced from 3.0
uniform float line_strength : hint_range(0.0, 1.0) = 0.3; // Reduced from 0.5

// CRT warping properties
uniform float curvature_x : hint_range(0.0, 0.2) = 0.03; // Reduced from 0.05
uniform float curvature_y : hint_range(0.0, 0.2) = 0.05; // Reduced from 0.08

// CRT properties
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.2; // Reduced from 0.3
uniform float brightness : hint_range(0.5, 2.0) = 1.1; // Reduced from 1.2
uniform float flicker_strength : hint_range(0.0, 0.1) = 0.01; // Reduced from 0.015

vec2 warp_screen(vec2 uv) {
    // Convert to -1 to 1 range
    vec2 curved_uv = uv * 2.0 - 1.0;
    
    // Barrel distortion
    float barrel = curved_uv.x * curved_uv.x + curved_uv.y * curved_uv.y;
    curved_uv.x += curved_uv.x * barrel * curvature_x;
    curved_uv.y += curved_uv.y * barrel * curvature_y;
    
    // Convert back to 0-1 range
    return curved_uv * 0.5 + 0.5;
}

void fragment() {
    // Apply CRT warping
    vec2 warped_uv = warp_screen(SCREEN_UV);
    
    // Use conditional assignment
    vec4 color;
    if (warped_uv.x < 0.0 || warped_uv.x > 1.0 || warped_uv.y < 0.0 || warped_uv.y > 1.0) {
        color = vec4(0.0, 0.0, 0.0, 1.0); // Black for out-of-bounds
    } else {
        // Sample the screen texture
        color = texture(SCREEN_TEXTURE, warped_uv);
        
        // Apply more subtle scanlines
        float scanline = pow(abs(sin(warped_uv.y * line_density * 3.14159)), line_sharpness);
        color.rgb *= 1.0 - (scanline * line_strength);
        
        // Apply vignette (darkens corners)
        vec2 vignette_uv = SCREEN_UV * 2.0 - 1.0;
        float vignette = 1.0 - dot(vignette_uv, vignette_uv) * vignette_strength;
        color.rgb *= vignette;
        
        // Apply subtle flicker
        float time_offset = mod(TIME, 100.0);
        float flicker = sin(time_offset * 10.0) * 0.5 + 0.5;
        color.rgb *= 1.0 - (flicker * flicker_strength);
        
        // Reduce RGB separation effect
        float r = texture(SCREEN_TEXTURE, warped_uv + vec2(0.0001, 0.0)).r; // Reduced from 0.001
        float g = color.g;
        float b = texture(SCREEN_TEXTURE, warped_uv - vec2(0.0001, 0.0)).b; // Reduced from 0.001
        color.rgb = vec3(r, g, b);
        
        // Apply brightness boost
        color.rgb *= brightness;
    }
    
    COLOR = color;
}