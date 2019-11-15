#version 330

uniform	mat4 m_pvm;
uniform	mat4 m_viewModel;
uniform	mat4 m_view;
uniform	mat3 m_normal;
uniform	vec3 l_dir; //Espaço global

in vec3 normal;		// local space

in vec4 position;	// local space
in vec2 texCoord0;	// local space

// the data to be sent to the fragment shader
out Data {
	vec2 texCoord;
	vec4 eye;
	vec3 normal;
	vec3 l_dir;
} DataOut;


void main () {
	DataOut.normal = normalize(m_normal * normal);
	DataOut.eye = -(m_viewModel * position);

	DataOut.l_dir = l_dir;
	// Pass-through the texture coordinates
	DataOut.texCoord = texCoord0;

	// transform the vertex coordinates
	gl_Position = m_pvm * position;	
}