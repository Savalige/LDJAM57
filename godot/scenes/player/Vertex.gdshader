shader_type canvas_item;

uniform bool affine_mapping = false;
uniform float jitter: hint_range(0.0, 0.5) = 0.25; // Use values less than 0.5 to avoid overlaps
uniform vec2 resolution = vec2(960.0, 540.0);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

// Simple hash function to generate pseudo-random values from a vec2.
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 snap_to_position(vec2 uv) {
    // Compute the fixed grid cell.
    vec2 cell = floor(uv * resolution);
    // Get the cell's origin in UV space.
    vec2 base_uv = cell / resolution;
    
    // Generate a random offset for each cell.
    // Two different seeds for x and y offsets.
    float offset_x = rand(cell);
    float offset_y = rand(cell + vec2(1.0, 1.0));
    
    // Scale the offset by jitter and by the size of one cell.
    vec2 cell_size = 1.0 / resolution;
    vec2 jitter_offset = vec2(offset_x, offset_y) * jitter * cell_size;
    
    return base_uv + jitter_offset;
}

void fragment() {
    // Get the jittered (snapped) UV coordinates.
    vec2 uv = snap_to_position(SCREEN_UV);
    
    // Sample the screen texture at the jittered coordinate.
    COLOR = texture(SCREEN_TEXTURE, uv);
    
    // Optionally apply affine mapping for additional effect.
    if (affine_mapping) {
        float distort_amount = 0.01;
        vec2 screen_pos = (SCREEN_UV - 0.5) * 2.0; // Map to -1 to 1 range.
        float distort = length(screen_pos) * distort_amount;
        COLOR.rgb *= (1.0 - distort);
    }
}
