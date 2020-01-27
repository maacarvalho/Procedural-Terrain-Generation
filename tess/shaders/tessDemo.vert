#version 410

in vec4 position;
out vec4 posV;

in float tesselation;
in float tesselationRatio;

out int ring;
out int ring_max;
out vec2 dir;

void main() {

    vec4 pos = vec4(0,0,0,0);

    // HARDCODED

    int instances = 25;
    int length = 2;

    int side = int(sqrt(instances));
    
    float offset = side * length * 0.5 - length * 0.5;

    int x = gl_InstanceID % side;
    int y = gl_InstanceID / side;

    int x_center = int(floor(instances * 0.5)) % side;
    int y_center = x_center;

    ring = max(abs(x - x_center), abs(y - y_center));
    ring_max = int(ceil(side / 2.0));
    
    dir = vec2(x - x_center, y - y_center);

    gl_Position = vec4(-offset, -offset, 0, 0) + position + vec4(x * length, y * length, 0, 0);
}



