#version 410

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;

layout(triangles) in;
layout(triangle_strip, max_vertices = 6) out;

in Attribs {
    vec4 couleur;
    float clipDistanceRayonsX;
} AttribsIn[];

out Attribs {
    vec4 couleur;
} AttribsOut;

void main(){

    for(int i = 0; i < gl_in.length(); i++){
        gl_ViewportIndex = 0;
        gl_ClipDistance[0] = AttribsIn[i].clipDistanceRayonsX;
        gl_Position = gl_in[i].gl_Position;
        AttribsOut.couleur = AttribsIn[i].couleur;
        EmitVertex();
    }
    EndPrimitive();

    for(int i = 0; i < gl_in.length(); i++){
        gl_ViewportIndex = 1;
        gl_ClipDistance[0] = AttribsIn[i].clipDistanceRayonsX;
        gl_Position = gl_in[i].gl_Position;
        AttribsOut.couleur = vec4(1.0 - AttribsIn[i].couleur.r, 1.0 - AttribsIn[i].couleur.g, 1.0 - AttribsIn[i].couleur.b, AttribsIn[i].couleur.a);
        EmitVertex();
    }
    EndPrimitive();
}