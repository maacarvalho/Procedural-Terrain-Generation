#version 330

uniform	mat4 m_pvm;

in vec4 position;	// local space
in vec2 texCoord0;	// local space

// The data to be sent to the fragment shader
out Data {

	vec2 texCoord;

} DataOut;


void main () {
	
	// Pass-through the texture coordinates
	DataOut.texCoord = texCoord0;

	// Transform the vertex coordinates
	gl_Position = m_pvm * position;	
}