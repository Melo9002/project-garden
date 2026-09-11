shader_type spatial;
render_mode diffuse_burley;
uniform vec4 moss_color : source_color = vec4(0.065, 0.12, 0.055, 1.0);
uniform vec4 grass_color : source_color = vec4(0.21, 0.30, 0.11, 1.0);
varying vec3 world_pos;
varying vec3 world_normal;
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453); }
float noise(vec2 p) {
 vec2 i=floor(p), f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);
}
void vertex() {
 world_pos = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
 world_normal = MODEL_NORMAL_MATRIX * NORMAL;
}
void fragment() {
 float patches = noise(world_pos.xz*0.6)*0.6 + noise(world_pos.xz*2.9)*0.25 + noise(world_pos.xz*24.0)*0.15;
 vec3 grass = mix(moss_color.rgb, grass_color.rgb, smoothstep(0.12,0.85,patches));
 float top = smoothstep(0.2,0.75,world_normal.y);
 ALBEDO = mix(vec3(0.20,0.23,0.15),grass,top);
 ROUGHNESS = 0.95;
}
