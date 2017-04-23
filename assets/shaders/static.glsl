
varying vec3 f_normal;

#ifdef VERTEX

attribute vec3 VertexNormal;

uniform mat4 u_model;
uniform mat4 u_proj;

vec4 position(mat4 _, vec4 vertex) {
    f_normal = mat3(u_model) * VertexNormal;
    return u_proj * u_model * vertex;
}

#endif


#ifdef PIXEL

vec4 effect(vec4 _col, Image s_color, vec2 _uv, vec2 _sc) {
    vec4 col = texture2D(s_color, _uv);
    return vec4(col.rgb, 1.0);
}

#endif
