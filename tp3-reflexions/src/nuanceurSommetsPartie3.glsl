#version 410

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;
uniform mat3 matrNormale;

/////////////////////////////////////////////////////////////////

layout(location=0) in vec4 Vertex;
layout(location=2) in vec3 Normal;
layout(location=3) in vec4 Color;
layout(location=8) in vec4 TexCoord;

out Attribs {
    vec4 couleur;
    vec3 N;
    vec2 TexCoord;
} AttribsOut;

void main( void )
{
    // transformation standard du sommet
    gl_Position = matrVisu * matrModel * Vertex;

    AttribsOut.N = Normal;
    AttribsOut.TexCoord = TexCoord.st;

    AttribsOut.couleur = Color;
}