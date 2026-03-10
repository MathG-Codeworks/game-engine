shader_type spatial;

uniform vec4 color1 : source_color = vec4(1.0);
uniform vec4 color2 : source_color = vec4(1.0);
uniform vec4 color3 : source_color = vec4(1.0);
uniform vec4 color4 : source_color = vec4(1.0);
uniform int player_count = 0;

varying vec3 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	vec4 final_color = vec4(1.0);

    float norm_x = local_pos.x + 0.5;
    float norm_z = local_pos.z + 0.5;
    
    if (player_count == 0) {
        final_color = vec4(1.0);
    } else if (player_count == 1) {
        final_color = color1;
    } else if (player_count == 2) {
        final_color = norm_x < 0.5 ? color1 : color2;
    } else if (player_count == 3) {
        if (norm_x < 0.33) final_color = color1;
        else if (norm_x < 0.66) final_color = color2;
        else final_color = color3;
    } else if (player_count >= 4) {
        if (norm_x < 0.5 && norm_z < 0.5) final_color = color1;
        else if (norm_x >= 0.5 && norm_z < 0.5) final_color = color2;
        else if (norm_x < 0.5 && norm_z >= 0.5) final_color = color3;
        else final_color = color4;
    }
    
    ALBEDO = final_color.rgb;
}