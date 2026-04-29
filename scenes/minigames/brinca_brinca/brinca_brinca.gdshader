shader_type sky;

uniform sampler2D sky_tex;
uniform float speed = 0.01;

void sky() {
    vec2 uv = SKY_COORDS;
    uv.x += TIME * speed;

    COLOR = texture(sky_tex, uv).rgb;
}