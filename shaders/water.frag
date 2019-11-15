#version 330

uniform	vec4 specular;
uniform	float shininess;

uniform sampler2D tex;

in Data {
	vec2 texCoord;
	vec4 eye;
	vec3 normal;
	vec3 l_dir;
} DataIn;

out vec4 outputF;

void main() {
	// set the specular term to black
	vec4 spec = vec4(0.0);

	// normalize both input vectors
	vec3 n = normalize(DataIn.normal);
	vec3 e = normalize(vec3(DataIn.eye));
	vec3 l = normalize(DataIn.l_dir);
	
	float intensity = max(dot(n,l), 0.0);

	// if the vertex is lit compute the specular color
	if (intensity > 0.0) {
		// compute the half vector
		vec3 h = normalize(l + e);	
		// compute the specular intensity
		float intSpec = max(dot(h,n), 0.0);
		// compute the specular term into spec
		spec = specular * pow(intSpec,shininess);
	}
	outputF = max(intensity *  texture(tex,DataIn.texCoord) + spec, texture(tex,DataIn.texCoord) * 0.25);
}