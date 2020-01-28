#version 420
 
layout(triangles) in;
layout (line_strip, max_vertices=6) out;

uniform mat4 projViewModelMatrix;
uniform float len = 1;

in vec3 normal[];
in vec4 x0[];
in vec4 x1[];
in vec4 z0[];
in vec4 z1[];

void main()
{
	// normal for first vertex
	gl_Position = projViewModelMatrix * gl_in[0].gl_Position;
	EmitVertex();

	gl_Position = projViewModelMatrix * (gl_in[0].gl_Position + len * vec4(normal[0],0.0));
	EmitVertex();

	EndPrimitive();
	

	// normal for second vertex
	gl_Position = projViewModelMatrix * gl_in[1].gl_Position;
	EmitVertex();

	gl_Position = projViewModelMatrix * (gl_in[1].gl_Position + len * vec4(normal[1], 0.0));
	EmitVertex();

	EndPrimitive();


	// normal for third vertex
	gl_Position = projViewModelMatrix * gl_in[2].gl_Position;
	EmitVertex();

	gl_Position = projViewModelMatrix * (gl_in[2].gl_Position + len * vec4(normal[2],0.0));
	EmitVertex();

	EndPrimitive();

	// ONLY X's

	// gl_Position = projViewModelMatrix * x0[0];
	// EmitVertex();

	// gl_Position = projViewModelMatrix * x1[0];
	// EmitVertex();

	// EndPrimitive();

	// gl_Position = projViewModelMatrix * x0[1];
	// EmitVertex();

	// gl_Position = projViewModelMatrix * x1[1];
	// EmitVertex();

	// EndPrimitive();

	// gl_Position = projViewModelMatrix * x0[2];
	// EmitVertex();

	// gl_Position = projViewModelMatrix * x1[2];
	// EmitVertex();

	// EndPrimitive();

	// // ONLY Z's

	// gl_Position = projViewModelMatrix * z0[0];
	// EmitVertex();

	// gl_Position = projViewModelMatrix * z1[0];
	// EmitVertex();

	// EndPrimitive();

	// gl_Position = projViewModelMatrix * z0[1];
	// EmitVertex();

	// gl_Position = projViewModelMatrix * z1[1];
	// EmitVertex();

	// EndPrimitive();
	
	// gl_Position = projViewModelMatrix * z0[2];
	// EmitVertex();

	// gl_Position = projViewModelMatrix * z1[2];
	// EmitVertex();

	// EndPrimitive();

	// CONECTS X'S TO PONTS

	// gl_Position = projViewModelMatrix * x0[0];
	// EmitVertex();

	// gl_Position = projViewModelMatrix * gl_in[0].gl_Position;
	// EmitVertex();

	// EndPrimitive();

	// gl_Position = projViewModelMatrix * x1[0];
	// EmitVertex();

	// gl_Position = projViewModelMatrix * gl_in[0].gl_Position;
	// EmitVertex();

	// EndPrimitive();

	// gl_Position = projViewModelMatrix * x0[1];
	// EmitVertex();

	// gl_Position = projViewModelMatrix * gl_in[1].gl_Position;
	// EmitVertex();

	// EndPrimitive();

	// gl_Position = projViewModelMatrix * x1[1];
	// EmitVertex();

	// gl_Position = projViewModelMatrix * gl_in[1].gl_Position;
	// EmitVertex();

	// EndPrimitive();

	// gl_Position = projViewModelMatrix * x0[2];
	// EmitVertex();

	// gl_Position = projViewModelMatrix * gl_in[2].gl_Position;
	// EmitVertex();

	// EndPrimitive();

	// gl_Position = projViewModelMatrix * x1[2];
	// EmitVertex();

	// gl_Position = projViewModelMatrix * gl_in[2].gl_Position;
	// EmitVertex();

	// EndPrimitive();

	
}

