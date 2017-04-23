
varying vec3 f_normal;

#ifdef VERTEX

attribute vec4 VertexWeight;
attribute vec4 VertexBone;
attribute vec3 VertexNormal;

uniform mat4 u_model;
uniform mat4 u_proj;
uniform mat4 u_pose[100];

vec4 position(mat4 _, vec4 vertex) {
    mat4 skeleton = u_pose[int(VertexBone.x*255.0)] * VertexWeight.x +
                    u_pose[int(VertexBone.y*255.0)] * VertexWeight.y +
                    u_pose[int(VertexBone.z*255.0)] * VertexWeight.z +
                    u_pose[int(VertexBone.w*255.0)] * VertexWeight.w;

    mat4 transform = u_model*skeleton;

    f_normal = mat3(transform) * VertexNormal;
    return u_proj * transform * vertex;
}

#endif


#ifdef PIXEL

vec4 effect(vec4 _col, Image s_color, vec2 _uv, vec2 _sc) {
    vec4 col = texture2D(s_color, _uv);
    return vec4(col.rgb, 1.0);
}

#endif
