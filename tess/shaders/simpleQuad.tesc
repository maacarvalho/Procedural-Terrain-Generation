#version 410

layout(vertices = 4) out;

in int ring[];
in int ring_max[];
in vec2 dir[];

out vec4 posTC[];

uniform float tessellationRatio = 0.5, tessellation = 16;

void main() {

	posTC[gl_InvocationID] = gl_in[gl_InvocationID].gl_Position;
	
	float tessLevelInner = tessellation * pow(tessellationRatio, ring[gl_InvocationID]);
	float tessLevelOuter = tessLevelInner * tessellationRatio;

	if (gl_InvocationID == 0) {

		gl_TessLevelOuter[0] = (dir[gl_InvocationID].x <= 0 && (abs(dir[gl_InvocationID].x) >= abs(dir[gl_InvocationID].y))) ? tessLevelOuter : tessLevelInner;
		gl_TessLevelOuter[1] = (dir[gl_InvocationID].y <= 0 && (abs(dir[gl_InvocationID].y) >= abs(dir[gl_InvocationID].x))) ? tessLevelOuter : tessLevelInner;
		gl_TessLevelOuter[2] = (dir[gl_InvocationID].x >= 0 && (abs(dir[gl_InvocationID].x) >= abs(dir[gl_InvocationID].y))) ? tessLevelOuter : tessLevelInner;
		gl_TessLevelOuter[3] = (dir[gl_InvocationID].y >= 0 && (abs(dir[gl_InvocationID].y) >= abs(dir[gl_InvocationID].x))) ? tessLevelOuter : tessLevelInner;

		gl_TessLevelInner[0] = tessLevelInner;
		gl_TessLevelInner[1] = tessLevelInner;

	}
}