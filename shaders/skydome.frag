#version 330

uniform sampler2D tex;

in Data {

	vec2 texCoord;

} DataIn;

out vec4 outputF;

void main() {

	outputF = texture(tex,DataIn.texCoord);

}