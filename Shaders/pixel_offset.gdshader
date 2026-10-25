shader_type canvas_item;

uniform vec2 cam_offset = vec2(0.0, 0.0);

//void vertex() {
//	VERTEX += cam_offset;
//}

void fragment() {
	COLOR = texture(TEXTURE, UV - cam_offset * TEXTURE_PIXEL_SIZE);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
