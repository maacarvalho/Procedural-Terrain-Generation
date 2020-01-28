#version 400
 
layout(triangles) in;
layout (triangles, max_vertices=3) out;

uniform	mat4 m_m_pvm;
uniform mat4 m_viewModel;

uniform vec3 camera_dir;

void main() {

	vec3 ps[3];
	for (int i = 0; i < 3; ++i)
		ps[i] = vec3(m_viewModel * gl_in[i].gl_Position);

	vec3 edge1 = ps[1] - ps[0];
	vec3 edge2 = ps[2] - ps[0];
	vec3 edge3 = ps[4] - ps[0];
	vec3 edge4 = ps[5] - ps[0];
	vec3 edge5 = ps[4] - ps[2];
	vec3 edge6 = ps[3] - ps[2];


	vec3 n = normalize(cross(edge1, edge2));
	vec3 n2 = normalize(cross(edge2, edge3));
	vec3 n4 = normalize(cross(edge3, edge4));
	vec3 n6 = normalize(cross(edge6, edge5));

	if (dot(n2, ps[0]) < 0)
		return;
		
	vec4 p[3];
	p[0] = m_pvm * gl_in[0].gl_Position;
	p[1] = m_pvm * gl_in[2].gl_Position;
	p[2] = m_pvm * gl_in[4].gl_Position;

	vec4 q[3];
	q[0] = m_pvm * gl_in[1].gl_Position;
	q[1] = m_pvm * gl_in[3].gl_Position;
	q[2] = m_pvm * gl_in[5].gl_Position;

	float crease = 0.1;
 	if (
	dot(n2,n) < crease 
	|| gl_in[0].gl_Position == gl_in[1].gl_Position
	|| 
	dot(n, ps[0]) < 0
	) 
	{
			gl_Position = p[0];
			EmitVertex();
 
			gl_Position = p[1];
			EmitVertex();

			EndPrimitive();
	}
	if (
	dot(n2,n4) < crease 
	|| gl_in[4].gl_Position == gl_in[5].gl_Position 
	|| 
	dot(n4, ps[0]) < 0
	) 
	{
			gl_Position = p[0];
			EmitVertex();
 
			gl_Position = p[2];
			EmitVertex();

			EndPrimitive();
	}
	if (
	dot(n2,n6) < crease 
	|| gl_in[2].gl_Position == gl_in[3].gl_Position
	|| 
	dot(n6, ps[0]) < 0
	) 
	{
			gl_Position = p[1];
			EmitVertex();
 
			gl_Position = p[2];
			EmitVertex();

			EndPrimitive();
	}
 
 }