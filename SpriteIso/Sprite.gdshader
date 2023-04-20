shader_type spatial;
render_mode skip_vertex_transform, blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx, unshaded;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture;
uniform sampler2D albedo_texture : filter_nearest, source_color;


void vertex() {
	// Pixel perfect sprite width and height
	const float PX = 0.01;
//	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), MODEL_MATRIX[3]);
	vec3 vert_3d = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX = vec3(floor(vert_3d.xy / PX) * PX, vert_3d.z);
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
}


void fragment() {
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	
	vec3 world = (VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	// Default depth calculation
	// vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	
	//// Depth sort based on Y position relative to camera. ////
	// Sprites do this based on world position
	float Y_CLIP_SPACE = (vec4(NODE_POSITION_VIEW.x, NODE_POSITION_VIEW.y, 0.0, 0.0) * VIEW_MATRIX * PROJECTION_MATRIX).y;
	
	// Position values range from -inf to +inf. 
	// What's on screen ranges from -1.0 to 1.0
	// Valid depth values range from 0.0 to 1.0
	// Clamp values to be within n amount of screens
	// and linearly spread values into the depth buffer
	
	const float IN_MIN = -5.0;
	const float IN_MAX = 5.0;
	// Inverted because "low" Y values should be far in depth
	float IN = clamp(Y_CLIP_SPACE * -1.0, IN_MIN, IN_MAX);
	const float IN_RANGE = IN_MAX - IN_MIN;

	const float OUT_MIN = 0.0;
	const float OUT_MAX = 1.0;
	const float OUT_RANGE = OUT_MAX - OUT_MIN;

	float my_depth = (IN - IN_MIN) * OUT_RANGE / IN_RANGE + OUT_MIN;
	
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	
	// 0.0 is near. 1.0 is far
	if (my_depth < depth) {
		ALBEDO = texture(albedo_texture, UV).rgb;
		ALPHA = texture(albedo_texture, UV).a;
		DEPTH = my_depth;
	} else {
		discard;
	}
}
