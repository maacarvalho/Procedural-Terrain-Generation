#version 400

uniform	vec4 specular;
uniform	float shininess;

uniform sampler2D moss_tex;
uniform sampler2D mossy_rock_tex;
uniform sampler2D rock_tex;
uniform sampler2D snow_tex;

uniform int texture_noise_octaves;
uniform float texture_noise_frequency;
uniform float texture_noise_power;
uniform float texture_noise_persistance;
uniform float texture_noise_lacunarity;

uniform int texture_divisions;

in Data {
	vec4 eye;
	vec3 normal;
	vec3 l_dir;
	float height;
	float inclination;
	vec2 texCoord;
} DataIn;

out vec4 colorOut;

//////////////////////////////////////////////////////////////////////////
//																		//
// Description : Array and textureless GLSL 2D simplex noise function.	//
//      Author : Ian McEwan, Ashima Arts.								//
//  Maintainer : stegu													//
//     Lastmod : 20110822 (ijm)											//
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.	//
//               Distributed under the MIT License. See LICENSE file.	//
//               https://github.com/ashima/webgl-noise					//
//               https://github.com/stegu/webgl-noise					//
// 																		//

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
  // First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

  // Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

  // Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

  // Gradients: 41 points uniformly over a line, mapped onto a diamond.
  // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

  // Normalise gradients implicitly by scaling m
  // Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

  // Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

//																		//
//////////////////////////////////////////////////////////////////////////


float max_noise () {

  float amp = 1, noise = 0;
	
	for(int i = 0; i < texture_noise_octaves; i++, amp *= texture_noise_persistance) {
		
    noise += 1.0 * amp;
	
  }

  return noise;

}

float noise (vec2 position) {

  float freq = texture_noise_frequency, amp = 1, noise = 0, max_noise = max_noise();
	
	for(int i = 0; i < texture_noise_octaves; i++, amp *= texture_noise_persistance, freq *= texture_noise_lacunarity) {
		
    noise += snoise(freq * position) * amp;
	
  }

  // Height -> [0,1]
  noise = noise / max_noise * 0.5 + 0.5;

  // Applying the power (height -> [0, 1])
  return pow(noise, texture_noise_power);
  
}

void main() {

	// get texture color
	// colorOut = vec4(0,0,0,1);
	
	vec4 color = vec4(0.23529, 0.14510, 0.08235, 1);

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
	//colorOut = max(intensity *  color + spec, color * 0.25);

	vec2 textCoordinates = DataIn.texCoord * texture_divisions - floor(DataIn.texCoord * texture_divisions);

	vec4 tex;

	if (DataIn.inclination <= 0.5) {
		
		tex = texture (rock_tex, textCoordinates);
		
	} else if (DataIn.inclination <= 0.8) {
		
		vec4 mossy_rock = texture (mossy_rock_tex, textCoordinates);
		vec4 rock = texture (rock_tex, textCoordinates);
		
		tex = mix (mossy_rock, rock, smoothstep(0.4, 0.5, DataIn.inclination));
	
	} else { 

		vec4 moss = texture(moss_tex, textCoordinates);
		vec4 mossy_rock = texture (mossy_rock_tex, textCoordinates);
		
		tex = mix (moss, mossy_rock, smoothstep(0.2, 0.3, DataIn.inclination));

	}

	if (DataIn.height > 0.8) {

		vec4 inclination_tex = tex;
		vec4 snow = texture(snow_tex, textCoordinates);

		tex = mix(inclination_tex, snow, smoothstep(0.8, 0.99, DataIn.height));

	} else if (DataIn.height > 1) tex = vec4(1, 0, 0, 1);
	
	// tex = texture(moss_tex, textCoordinates);

	colorOut = max(intensity *  tex + spec, tex * 0.25);
	
}