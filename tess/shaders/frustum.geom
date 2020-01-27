#version 420
 
#define M_PI 3.1415926535897932384626433832795

layout(triangles) in;
layout (triangle_strip, max_vertices=3) out;

uniform	mat4 projectionMatrix;
uniform mat4 viewModelMatrix;

uniform float cam_near;
uniform float cam_far;
uniform float cam_fov;

float vec3_sum (vec3 vec) { return vec.x + vec.y + vec.z; }

float distance (vec3 plane_normal, float d, vec3 pos) { return (vec3_sum(plane_normal * pos) + d) / length(plane_normal); }

// Explore culling option

void main()
{

	vec3 p[3];
	for (int i = 0; i < 3; ++i) p[i] = vec3(viewModelMatrix * gl_in[i].gl_Position);

	vec3 up = vec3(0,1,0);
	vec3 r =  vec3(1,0,0);

	// Center of near and far planes
	vec3 near_center = 			vec3(0,0,-cam_near);
	vec3 far_center = 			vec3(0,0,-cam_far);

	// Tangent of the fov
	float tg = 					tan(cam_fov * M_PI / 180.0);

	// Width and Height of near and far planes
	float w_far = 				abs(cam_far * tg);
	float w_near = 				abs(cam_near * tg);

	float h_far = 				w_far;
	float h_near = 				w_near;

	// Edges of near plane
	vec3 near_top_left = 		near_center + h_far * 0.5 * up - r * 0.5 * w_far;
	vec3 near_top_right = 		near_center + h_far * 0.5 * up + r * 0.5 * w_far;
	vec3 near_bottom_left = 	near_center - h_far * 0.5 * up - r * 0.5 * w_far;
	vec3 near_bottom_right = 	near_center - h_far * 0.5 * up + r * 0.5 * w_far;

	// Edges of near plane
	vec3 far_top_left = 		far_center + h_far * 0.5 * up - r * 0.5 * w_far;
	vec3 far_top_right = 		far_center + h_far * 0.5 * up + r * 0.5 * w_far;
	vec3 far_bottom_left = 		far_center - h_far * 0.5 * up - r * 0.5 * w_far;
	vec3 far_bottom_right = 	far_center - h_far * 0.5 * up + r * 0.5 * w_far;
	
	// Planes normals ([0] - left, [1] - right, [2] - top, [3] - bottom)
	vec3 normal[4];
	normal[0] =	 				normalize( cross( far_bottom_left - near_bottom_left , near_top_left - near_bottom_left ) );
	normal[1] =	 				normalize( cross( far_top_right - near_top_right , near_bottom_right - near_top_right ) );
	normal[2] =		 			normalize( cross( far_top_left - near_top_left , near_top_right - near_top_left ) );
	normal[3] = 				normalize( cross( far_bottom_right - near_bottom_right , near_bottom_left - near_bottom_right ) );

	// Planes d's ([0] - left, [1] - right, [2] - top, [3] - bottom)
	float d[4];
	d[0] =						-vec3_sum(normal[0].xyz * far_bottom_left.xyz);
	d[1] =						-vec3_sum(normal[1].xyz * far_top_right.xyz);
	d[2] =						-vec3_sum(normal[2].xyz * far_top_left.xyz);
	d[3] =						-vec3_sum(normal[3].xyz * far_bottom_right.xyz);

	// Actually calculate distances
	int points_outside = 0;
	for (int i = 0; i < 3; ++i) {

		if (p[i].z > -cam_near || p[i].z < -cam_far) {points_outside++; continue;}
		for (int j = 0; j < 4; ++j) 
			if (distance(normal[j], d[j], p[i]) < 0) {points_outside++; break; }

	}

	// Only if all points are not outside, the vertices are emitted
	if (points_outside != 3) {
		
		gl_Position = projectionMatrix * vec4(p[0].x, p[0].y, p[0].z, 1);
		EmitVertex();
		gl_Position = projectionMatrix * vec4(p[1].x, p[1].y, p[1].z, 1);
		EmitVertex();
		gl_Position = projectionMatrix * vec4(p[2].x, p[2].y, p[2].z, 1);
		EmitVertex();

			
	} 

	EndPrimitive();
 }