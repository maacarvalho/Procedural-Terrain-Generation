#version 410

uniform	vec4 specular;
uniform	float shininess;

uniform sampler2D moss_tex;
uniform sampler2D mossy_rock_tex;
uniform sampler2D rock_tex;
uniform sampler2D snow_tex;

in Data {

	vec3 normal;
	float height;
	vec3 eye;
	vec3 light_dir;
	vec2 texCoord;

} DataIn;

out vec4 outputF;

void main() {

	//outputF = vec4(0.3,0.3,0.3,0);

	vec4 color = vec4(0.23529, 0.14510, 0.08235, 1);
	
	//outputF = color;

	// Setting the specular term to black
	vec4 spec = vec4(0.0);

	float intensity = max(dot(DataIn.normal,DataIn.light_dir), 0.0);

	// If the vertex is lit compute the specular color
	if (intensity > 0.0) {
		// Computing the half vector
		vec3 h = normalize(DataIn.light_dir + DataIn.eye);	
		// compute the specular intensity
		float intSpec = max(dot(h,DataIn.normal), 0.0);
		// compute the specular term into spec
		spec = specular * pow(intSpec, shininess);
	}

	//outputF = max(intensity * color + spec, color * 0.25);

	vec2 textCoordinates = DataIn.texCoord;
	//vec2 textCoordinates = vec2(0,0);

	vec4 tex;

	if (DataIn.normal.y <= 0.5) {
		
		tex = texture (rock_tex, textCoordinates);
		
	} else if (DataIn.normal.y <= 0.8) {
		
		vec4 mossy_rock = texture (mossy_rock_tex, textCoordinates);
		vec4 rock = texture (rock_tex, textCoordinates);
		
		tex = mix (mossy_rock, rock, smoothstep(0.4, 0.5, DataIn.normal.y));
	
	} else { 

		vec4 moss = texture(moss_tex, textCoordinates);
		vec4 mossy_rock = texture (mossy_rock_tex, textCoordinates);
		
		tex = mix (moss, mossy_rock, smoothstep(0.2, 0.3, DataIn.normal.y));

	}

	if (DataIn.height > 0.8) {

		vec4 inclination_tex = tex;
		vec4 snow = texture(snow_tex, textCoordinates);

		tex = mix(inclination_tex, snow, smoothstep(0.8, 0.99, DataIn.height));

	} else if (DataIn.height > 1) tex = vec4(1, 0, 0, 1);
	
	//tex = texture(moss_tex, textCoordinates);

	outputF = max(intensity *  tex + spec, tex * 0.25);
	//outputF = max(intensity * color + spec, color * 0.25);

}