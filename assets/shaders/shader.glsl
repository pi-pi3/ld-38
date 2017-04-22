
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

//uniform vec4 u_light;
const float exposure = 1.5;
const float gamma = 2.2;

vec4 effect(vec4 _col, Image s_color, vec2 _uv, vec2 _sc) {
    // temporary
    vec4 u_light = vec4(0.0, 0.0, -1.0, 1.0)

    vec4 color  = gammaToLinear(_col);
    vec3 normal = normalize(f_normal);
    float shade = max(0.0, dot(normal, u_light.xyz));
    color.rgb *= shade;
    color.rgb *= u_light.w;

    // RomBinDaHouse
    color.rgb = exp( -1.0 / ( 2.72*color.rgb + 0.15 ) );
    color.rgb = pow(color.rgb, vec3(1.0 / gamma));

    return vec4(color.rgb, 1.0);
}

#endif
