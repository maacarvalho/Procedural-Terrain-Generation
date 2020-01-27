#version 420

layout(triangles) in;
layout (triangle_strip, max_vertices=3) out;

uniform	mat4 projectionMatrix;
uniform mat4 viewModelMatrix;

void main()
{

	vec3 p[3];
	for (int i = 0; i < 3; ++i) p[i] = vec3(viewModelMatrix * gl_in[i].gl_Position);

	gl_Position = projectionMatrix * vec4(p[0].x, p[0].y, p[0].z, 1);
	EmitVertex();
	gl_Position = projectionMatrix * vec4(p[1].x, p[1].y, p[1].z, 1);
	EmitVertex();
	gl_Position = projectionMatrix * vec4(p[2].x, p[2].y, p[2].z, 1);
	EmitVertex();

	EndPrimitive();
 }