#version 400

uniform	mat4 m_pvm;

uniform float n_frequency;
uniform float n_amplitude;
uniform int octaves;
uniform float persistance;
uniform float lacunarity;

in vec4 position;	// local space

// the data to be sent to the fragment shader
out vec4 color;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// Simplex 2D noise

vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

float snoise(vec2 v){
  
  const vec4 C = vec4(
    0.211324865405187, 
    0.366025403784439,
    -0.577350269189626, 
    0.024390243902439);

  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);
  vec2 i1;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod(i, 289.0);
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
  + i.x + vec3(0.0, i1.x, 1.0 ));
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
    dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

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
	
  color = vec4(1,1,1,1) * (height(position.xz) / max_height() * 0.5 + 0.5);
	//float random = rand(position.xz);

	gl_Position = m_pvm * position;	
}