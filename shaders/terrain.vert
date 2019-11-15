#version 400

uniform	mat4 m_pvm;
uniform	mat4 m_viewModel;
uniform	mat4 m_view;
uniform	mat3 m_normal;

uniform	vec4 l_dir;	   // global space

uniform float n_frequency;
uniform float n_amplitude;
uniform int octaves;
uniform float persistance;
uniform float lacunarity;

uniform vec2 grid_origin;
uniform float grid_length;
uniform uint grid_divisions;

in vec4 position;	// local space
in vec3 normal;		// local space

// the data to be sent to the fragment shader
out Data {
	vec4 eye;
	vec3 normal;
	vec3 l_dir;
  float height;
} DataOut;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

/////////////////////////////////////////////////////////////////////////
//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : stegu
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//               https://github.com/stegu/webgl-noise
// 
//
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
//
/////////////////////////////////////////////////////////////////////////

float height (vec2 position) {

  float freq = n_frequency, amp = n_amplitude, height = 0;
	
	for(int i = 0; i < octaves; i++, amp *= persistance, freq *= lacunarity) {
		
    height += snoise(freq * position) * amp;
	
  }

  return height;
  
}

float max_height () {

  float amp = n_amplitude, height = 0;
	
	for(int i = 0; i < octaves; i++, amp *= persistance) {
		
    height += 1.0 * amp;
	
  }

  return height;

}

void main () {
	
  vec4 origin_pos = vec4(0, 0, 0, 0);

	//DataOut.texCoord = texCoord0;
	DataOut.eye = -(m_viewModel * position);
	DataOut.l_dir = normalize(vec3(m_view * -l_dir));

  vec2 height_pos = position.xz + grid_origin;

  // Calculatin the new height of our current position
  vec4 new_pos = position + vec4(0, height(position.xz), 0, 0);
  //vec4 new_pos = position + vec4(0, height(height_pos), 0, 0) + origin_pos;

  // Sending the new height normalized between -1 and 1
  DataOut.height = new_pos.y / max_height();

  float grid_step = grid_length / grid_divisions;

  // Getting the adjacent points to update the normal after height changes
  vec4 adj_pos_x;
  vec4 adj_pos_z;

  // Booleans that check if the next adjacent points are off the grid
  bool at_border_x = position.x + grid_step < origin_pos.x + grid_length / 2;
  bool at_border_z = position.z + grid_step < origin_pos.z + grid_length / 2;

  if (!at_border_x) adj_pos_x = position + vec4(grid_step,0,0,0);
  else adj_pos_x = position - vec4(grid_step,0,0,0);

  if (!at_border_z) adj_pos_z = position + vec4(0,0,grid_step,0);
  else adj_pos_z = position - vec4(0,0,grid_step,0);

  // Calculating the heights of the adjacent points using the simplex
  adj_pos_x += vec4(0, height(adj_pos_x.xz), 0, 0);
  adj_pos_z += vec4(0, height(adj_pos_z.xz), 0, 0);

  // Calculating the vectors whose cross product will return the normal
  vec4 vecX = normalize(adj_pos_x - new_pos);
  vec4 vecZ = normalize(adj_pos_z - new_pos);

  // Recalculating the normal at the current position
  vec3 new_normal;
  
  if ((at_border_x && !at_border_z) || (at_border_z && !at_border_x)) new_normal = cross(vecX.xyz, vecZ.xyz);
  else new_normal = cross(vecZ.xyz, vecX.xyz);

  DataOut.normal = normalize(m_normal * new_normal);

  gl_Position = m_pvm * new_pos;	
  
}