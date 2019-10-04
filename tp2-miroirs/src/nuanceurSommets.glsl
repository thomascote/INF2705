#version 410

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;

uniform vec4 planRayonsX; // équation du plan de RayonsX

uniform int attenuation; // on veut une atténuation en profondeur ?

layout(location=0) in vec4 Vertex;
layout(location=3) in vec4 Color;

out Attribs {
    vec4 couleur;
    float clipDistanceRayonsX;
} AttribsOut;

void main( void )
{
    // transformation standard du sommet

    gl_Position = matrProj * matrVisu * matrModel * Vertex;
    vec4 pos = matrModel * Vertex;
    AttribsOut.clipDistanceRayonsX = dot(planRayonsX,pos);

    // couleur du sommet
    AttribsOut.couleur = Color;

    if((Color.r - 0.0) < 0.05 && (Color.g - 1.0) < 0.05 && (Color.b - 0.0) < 0.05){
        const vec4 coulAttenuation = vec4( 0.0, 1.0, 1.0, 1.0 );
        AttribsOut.couleur = mix(Color, coulAttenuation, Vertex.z );
    }

    // atténuer selon la profondeur
    if ( attenuation == 1 )
    {
        const float debAttenuation = -12.0;
        const float finAttenuation = +5.0;
        const vec4 coulAttenuation = vec4( 0.2, 0.15, 0.1, 1.0 );

        float  smoothstep = smoothstep( debAttenuation, finAttenuation, pos.z );
        AttribsOut.couleur = mix(coulAttenuation, AttribsOut.couleur, smoothstep );

        // Mettre un test bidon afin que l'optimisation du compilateur n'élimine l'attribut "planRayonsX".
        // Vous ENLEVEREZ ce test inutile!
        if ( planRayonsX.x < -10000.0 ) AttribsOut.couleur.r += 0.001;
    }
}
