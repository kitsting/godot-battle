shader_type canvas_item;
uniform sampler2D noise;
void fragment() {
    vec2 uv = vec2(UV.x + TIME, UV.y);
    COLOR.rgb = texture(TEXTURE, uv).rgb;
}
