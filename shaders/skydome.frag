#version 330

uniform sampler2D tex;

in Data {

	float height;
	vec2 texCoord;

} DataIn;

out vec4 outputF;

void main() {

	//if (DataIn.height >= 0)
		outputF = texture(tex,DataIn.texCoord);
	//else 
		//outputF = vec4(0,0,0,1);

}