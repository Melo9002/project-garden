shader_type spatial;
render_mode unshaded;
uniform vec4 deep_color : source_color = vec4(0.085,0.23,0.25,1.0);
uniform vec4 reflection_color : source_color = vec4(0.39,0.57,0.56,1.0);
uniform float ripple_speed : hint_range(0.0, 2.0) = 0.3;
varying vec3 world_pos;
void vertex() { world_pos=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment() {
 vec2 p=world_pos.xz;
 float t=TIME*ripple_speed;
 float bend=sin(p.x*1.7+p.y*0.7+t)*0.16+sin(p.x*0.61-t)*0.2;
 float waves=sin(p.y*13.0+bend*6.0+t*2.0)*0.5+0.5;
 float crossing=sin(p.x*4.0+p.y*1.5-t)*0.5+0.5;
 float glints=pow(waves,22.0)*smoothstep(0.5,0.95,crossing);
 float reflected=0.2+0.1*sin(p.y*1.2+bend)+0.08*sin(p.x*0.6+p.y*2.0);
 vec3 color=mix(deep_color.rgb,reflection_color.rgb,reflected);
 ALBEDO=color+vec3(0.33,0.42,0.35)*glints*0.28;
}
