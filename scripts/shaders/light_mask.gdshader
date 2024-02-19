shader_type canvas_item;
uniform sampler2D light_source;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.rgb = COLOR.rgb;
	COLOR.r = 1.0;
	COLOR.a = texture(light_source, UV).r;
}

//void light() {
	 //Called for every pixel for every light affecting the CanvasItem.
	 //Uncomment to replace the default light processing function with this one.
//}
