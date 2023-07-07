shader_type canvas_item;

uniform vec4 tint : source_color = vec4(1., 1., 0., 1);
uniform float progress: hint_range(0.0,1.0);

void fragment() {
	vec4 tint_copy = tint;
	vec4 previous_color = texture(TEXTURE, UV);
	
	tint_copy.a = previous_color.a;
	COLOR = mix(previous_color, tint_copy, progress);
	
}