#version 330

uniform	mat4 m_projView;
uniform	mat4 m_model;

in vec4 position;	// local space
in vec2 texCoord0;	// local space

uniform vec4 camera_pos; // global space

// The data to be sent to the fragment shader
out Data {

	float height;
	vec2 texCoord;

} DataOut;


void main () {
	
	// Pass-through the texture coordinates
	DataOut.texCoord = texCoord0;
	DataOut.height = position.y;

	// Transform the vertex coordinates
	//gl_Position = m_projView * ((m_model * position) + vec4(camera_pos.x, 0, camera_pos.z + 8, 0));	
	gl_Position = m_projView * (m_model * position);	
	
}