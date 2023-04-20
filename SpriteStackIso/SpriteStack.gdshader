shader_type spatial;
render_mode skip_vertex_transform, blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx, unshaded;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture;
uniform sampler2D albedo_texture : filter_nearest, source_color;
uniform ivec2 size; // columns, rows


varying flat vec4 instance_custom;


void vertex() {
	// Pixel perfect sprite width and height
	const float PX = 0.01;
	vec3 vert_3d = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX = vec3(floor(vert_3d.xy / PX) * PX, vert_3d.z);
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	instance_custom = INSTANCE_CUSTOM;
}


float change_range(float old, float oldMin, float oldMax, float newMin, float newMax) {
	// Shrink range so there's enough room to show stacks
	float oldRange = oldMin - oldMax;
	float newRange = newMin - newMax;
	return (((old - oldMin) * newRange) / oldRange) + newMin;
}


// Gets color on layer.
// layer: index of layer in interval {0 < uv < layer_count}
// uv: coord of color in interval {0 < uv < 1.0}
// LIMITATION: Out of bounds will repeat the outermost pixel!
// FIX: Keep a transparent border around all layers
 vec4 getColorOnLayer(int layer, vec2 uv) {
	int columns = size.x;
	int rows = size.y;
	vec2 layer_size = vec2(1.0 / float(columns), 1.0 / float(rows));
	vec2 layer_start = vec2(float(layer % columns), float(layer / columns)) * layer_size;
	// HACK: - 0.000001 prevents overflowing into nearby sprites in the sheet
	return texture(albedo_texture, clamp(layer_start + layer_size * uv, layer_start, layer_start + layer_size - 0.000001));
}


void fragment() {
	int offset = int(instance_custom.r);
	
	
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	
	vec3 world = (VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	//// Depth sort based on Y position relative to camera. ////
	// Spite stacks do this per pixel
//	float y_clip_space = (vec4(NODE_POSITION_VIEW.x, NODE_POSITION_VIEW.y, 0.0, 0.0) * VIEW_MATRIX * PROJECTION_MATRIX).y;
	float y_clip_space = change_range(SCREEN_UV.y, 0.0, 1.0, -1.0, 1.0);
	
	// Position values range from -inf to +inf. 
	// What's on screen ranges from -1.0 to 1.0
	// Valid depth values range from 0.0 to 1.0
	// Clamp values to be within n amount of screens
	// and linearly spread values into the depth buffer
	
	// Max it out around 5 screen
	// Inverted because "low" Y values should be far in depth
	float y_clip_capped = clamp(y_clip_space * -1.0, -5.0, 5.0);
	float my_depth = change_range(y_clip_capped, -5.0, 5.0, 0.0, 1.0);
	
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	
	// 0.0 is near. 1.0 is far
	if (my_depth < depth) {
		vec4 color = getColorOnLayer(offset, UV);
		ALBEDO = color.rgb;
		ALPHA = color.a;
		DEPTH = my_depth;
	} else {
		discard;
	}
}
