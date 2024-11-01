shader_type canvas_item;
uniform float scroll_speed_x : hint_range(-2,2) = 1;
uniform float scroll_speed_y : hint_range(-2,2) = 1;
uniform sampler2D noise;
void fragment() {
    vec2 uv = vec2(UV.x + (TIME * scroll_speed_x), UV.y + (TIME * scroll_speed_y));
    COLOR.rgb = texture(TEXTURE, uv).rgb;
}
