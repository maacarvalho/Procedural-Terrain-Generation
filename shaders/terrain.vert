#version 410

in vec4 position;

uniform vec4 camera_pos; // global space

uniform mat4 m_model;

//uniform uint instances;

out Data {

    int ring;
    int ring_max;
    vec2 dir;
    int side;
    int patch_length;
    vec4 origin;

} DataOut;

void main() {

    // HARDCODED

    int instances = 15625;
    DataOut.patch_length = 2;

    DataOut.side = int(sqrt(instances));
    
    float offset = DataOut.side * DataOut.patch_length * 0.5 - DataOut.patch_length * 0.5;

    int x = gl_InstanceID % DataOut.side;
    int z = gl_InstanceID / DataOut.side;

    int x_center = int(floor(instances * 0.5)) % DataOut.side;
    int z_center = x_center;

    DataOut.ring = max(abs(x - x_center), abs(z - z_center));
    DataOut.ring_max = int(ceil(DataOut.side * 0.5));
    
    DataOut.dir = vec2(x - x_center, z - z_center);

    vec4 camera_offset = vec4( (camera_pos.x > 0) ? floor(camera_pos.x / DataOut.patch_length) * DataOut.patch_length : ceil(camera_pos.x / DataOut.patch_length) * DataOut.patch_length, 
                        0, 
                        (camera_pos.z > 0) ? floor(camera_pos.z / DataOut.patch_length) * DataOut.patch_length : ceil(camera_pos.z / DataOut.patch_length) * DataOut.patch_length,
                        0);

    DataOut.origin = vec4(0, 0, 0, 1) * m_model + // To Global state
                     camera_offset; // Moving with camera

    gl_Position = position * m_model + // To Global state
                  vec4(-offset, 0, -offset, 0) + // Centering the grid on (0,0)
                  vec4(x * DataOut.patch_length, 0, z * DataOut.patch_length, 0) + // Current patch place
                  camera_offset; // Moving with camera
}



