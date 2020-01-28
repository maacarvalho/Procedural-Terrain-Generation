#version 400

uniform	mat4 m_pvm;
uniform	mat4 m_viewModel;
uniform	mat4 m_model;
uniform	mat4 m_projectionView;
uniform	mat4 m_view;
uniform	mat3 m_normal;

uniform vec4 camera_pos; // global space

uniform	vec4 l_dir;	   // global space

uniform float height_noise_frequency;
uniform float height_noise_amplitude;
uniform float height_noise_power;
uniform int height_noise_octaves;
uniform float height_noise_persistance;
uniform float height_noise_lacunarity;

uniform float grid_length;
uniform uint grid_divisions;

in vec4 position;	// local space
in vec3 normal;		// local space

in vec2 texCoord0;	// local space

out int ring;
out int ring_max;
out vec2 dir;

// the data to be sent to the fragment shader
out Data {
  vec4 eye;
	vec3 normal;
	vec3 l_dir;
  float height;
  float inclination;
  vec2 texCoord;
} DataOut;

mat3 mat4_2_mat3(mat4 m4) {
  return mat3(
      m4[0][0], m4[0][1], m4[0][2],
      m4[1][0], m4[1][1], m4[1][2],
      m4[2][0], m4[2][1], m4[2][2]);
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Description : Array and textureless GLSL 2D simplex noise function.    //
//      Author : Ian McEwan, Ashima Arts.                                 //
//  Maintainer : stegu                                                    //
//     Lastmod : 20110822 (ijm)                                           //
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.     //
//               Distributed under the MIT License. See LICENSE file.     //
//               https://github.com/ashima/webgl-noise                    //
//               https://github.com/stegu/webgl-noise                     //
//                                                                        //
//                                                                        //

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
//                                                                        //
////////////////////////////////////////////////////////////////////////////

float max_height () {

  float amp = height_noise_amplitude, height = 0;
	
	for(int i = 0; i < height_noise_octaves; i++, amp *= height_noise_persistance) {
		
    height += 1.0 * amp;
	
  }

  return height;

}

float height (vec2 position) {

  float freq = height_noise_frequency, amp = height_noise_amplitude, height = 0, max_height = max_height();
	
  // Calculating height using snoise ( height -> [-max_height, max_heigth] )
	for(int i = 0; i < height_noise_octaves; i++, amp *= height_noise_persistance, freq *= height_noise_lacunarity) {
		
    height += snoise(freq * position) * amp;
	
  }

  // Height -> [0,1]
  height = height / max_height * 0.5 + 0.5;

  // Applying the power (height -> [0, 1])
  height = pow(height, height_noise_power);

  // Height -> [-1, max_height - 1]
  return height * 2 * max_height - 1;
  
}

void main () {

// TODO:

  DataOut.texCoord = texCoord0;
	DataOut.eye = -(m_viewModel * position);
	DataOut.l_dir = normalize(vec3(m_view * -l_dir));

// ---------------------------------------------------

  int instances = 16;
  int length = 2;

  int side = int(sqrt(instances));
  
  float grid_step = length;
  float grid_length = side * 2;

  float offset = side * length * 0.5 - length * 0.5;

  int x = gl_InstanceID % side;
  int y = gl_InstanceID / side;

  int x_center = int(floor(instances * 0.5)) % side;
  int y_center = x_center;

  ring = max(abs(x - x_center), abs(y - y_center));
  ring_max = int(ceil(side / 2.0));
    
  dir = vec2(x - x_center, y - y_center);

  //vec4 pos_world = (m_model * position) + vec4(camera_pos.x, camera_pos.y, camera_pos.z + 8, 0);
  vec4 pos_world = (m_model * position) + vec4(camera_pos.x, 0, camera_pos.z + 8, 0) + vec4(-offset, -offset, 0, 0) + vec4(x * length, y * length, 0, 0);


// ---------------------------------------------------


  vec2 height_pos = pos_world.xz;

  // Calculatin the new height of our current pos_world
  vec4 new_pos = pos_world + vec4(0, height(pos_world.xz), 0, 0);
  //vec4 new_pos = pos_world + vec4(0, height(height_pos), 0, 0) + origin_pos;

// ---------------------------------------------------

  // Sending the new height normalized between 0 and 1
  //DataOut.height = (new_pos.y + 1 - camera_pos.y) / max_height();
  DataOut.height = (new_pos.y + 1) / max_height();

  //float grid_step = grid_length / grid_divisions;

  // Getting the adjacent points to update the normal after height changes
  vec4 adj_pos_x;
  vec4 adj_pos_z;

  // Booleans that check if the next adjacent points are off the grid
  bool at_border_x = pos_world.x + grid_step < camera_pos.x + grid_length / 2;
  bool at_border_z = pos_world.z + grid_step < camera_pos.z + grid_length / 2;

  if (!at_border_x) adj_pos_x = pos_world + vec4(grid_step,0,0,0);
  else adj_pos_x = pos_world - vec4(grid_step,0,0,0);

  if (!at_border_z) adj_pos_z = pos_world + vec4(0,0,grid_step,0);
  else adj_pos_z = pos_world - vec4(0,0,grid_step,0);

  // Calculating the heights of the adjacent points using the simplex
  adj_pos_x += vec4(0, height(adj_pos_x.xz), 0, 0);
  adj_pos_z += vec4(0, height(adj_pos_z.xz), 0, 0);

  // Calculating the vectors whose cross product will return the normal
  vec4 vecX = normalize(adj_pos_x - new_pos);
  vec4 vecZ = normalize(adj_pos_z - new_pos);

  // Recalculating the normal at the current pos_world
  vec3 new_normal;
  
  if ((at_border_x && !at_border_z) || (at_border_z && !at_border_x)) new_normal = cross(vecX.xyz, vecZ.xyz);
  else new_normal = cross(vecZ.xyz, vecX.xyz);

// ---------------------------------------------

  //DataOut.normal = normalize(m_normal * new_normal);
  DataOut.normal = normalize(transpose(inverse(mat4_2_mat3(m_view))) * new_normal);  
  DataOut.inclination = new_normal.y;

  gl_Position = m_projectionView * new_pos;	
  
}