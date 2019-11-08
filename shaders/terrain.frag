#version 400

uniform	vec4 diffuse;
uniform	vec4 specular;
uniform	float shininess;

uniform vec4 color0;
uniform vec4 color1;
uniform vec4 color2;
uniform vec4 color3;
uniform vec4 color4;
uniform vec4 color5;
uniform vec4 color6;
uniform vec4 color7;
uniform vec4 color8;
uniform vec4 color9;

in Data {
	vec4 eye;
	vec3 normal;
	vec3 l_dir;
	float height;
} DataIn;

out vec4 colorOut;

void main() {

	// get texture color
	// colorOut = vec4(0,0,0,1);
	
	vec4 color;

	if (DataIn.height < -0.8) color = color0;
	else if (DataIn.height < -0.6) color = color1;
	else if (DataIn.height < -0.4) color = color2;
	else if (DataIn.height < -0.2) color = color3;
	else if (DataIn.height < 0) color = color4;
	else if (DataIn.height < 0.2) color = color5;
	else if (DataIn.height < 0.4) color = color6;
	else if (DataIn.height < 0.6) color = color7;
	else if (DataIn.height < 0.8) color = color8;
	else color = color9;

	// set the specular term to black
	vec4 spec = vec4(0.0);

	// normalize both input vectors
	vec3 n = normalize(DataIn.normal);
	vec3 e = normalize(vec3(DataIn.eye));
	vec3 l = DataIn.l_dir;
	
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
	colorOut = max(intensity *  color + spec, color * 0.25);
	// colorOut = color;
	
}