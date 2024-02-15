shader_type canvas_item;
render_mode light_only;
uniform sampler2D tendrils;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 screen = texture(screen_texture, SCREEN_UV).rgb;
	COLOR.rgb *= screen - vec3(0.1, 0.1, 0.1);
	COLOR.a = texture(TEXTURE, UV).a;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
