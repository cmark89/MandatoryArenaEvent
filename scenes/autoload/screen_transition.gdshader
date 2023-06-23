shader_type canvas_item;

uniform sampler2D transition_texture: filter_nearest;
uniform float percent: hint_range(0.0, 1.0);
uniform vec4 color: source_color;

void fragment() {
	// Place fragment code here.
	vec4 transition_color = texture(transition_texture, UV);
	if (transition_color.r > percent) {
		COLOR.a = 0.0;
	} else {
		COLOR = color;
	}
}