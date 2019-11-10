#version 410

// Définition des paramètres des sources de lumière
layout (std140) uniform LightSourceParameters
{
    vec4 ambient[3];
    vec4 diffuse[3];
    vec4 specular[3];
    vec4 position[3];      // dans le repère du monde
} LightSource;

// Définition des paramètres des matériaux
layout (std140) uniform MaterialParameters
{
    vec4 emission;
    vec4 ambient;
    vec4 diffuse;
    vec4 specular;
    float shininess;
} FrontMaterial;

// Définition des paramètres globaux du modèle de lumière
layout (std140) uniform LightModelParameters
{
    vec4 ambient;       // couleur ambiante globale
    bool twoSide;       // éclairage sur les deux côtés ou un seul?
} LightModel;

layout (std140) uniform varsUnif
{
    // partie 1: illumination
    int typeIllumination;     // 0:Gouraud, 1:Phong
    bool utiliseBlinn;        // indique si on veut utiliser modèle spéculaire de Blinn ou Phong
    bool afficheNormales;     // indique si on utilise les normales comme couleurs (utile pour le débogage)
    // partie 2: texture
    int numTexCoul;           // numéro de la texture de couleurs appliquée
    int numTexNorm;           // numéro de la texture de normales appliquée
    int afficheTexelFonce;    // un texel foncé doit-il être affiché 0:normalement, 1:mi-coloré, 2:transparent?
};

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;
uniform mat3 matrNormale;

/////////////////////////////////////////////////////////////////

layout(quads) in;

in Attribs {
    vec4 couleur;
    vec3 N;
    vec2 TexCoord;
} AttribsIn[];

out Attribs {
    vec4 couleur;
    vec3 L[3];
    vec3 O;
    vec3 N;
    vec2 TexCoord;
} AttribsOut;

vec4 calculerReflexion( in int j, in vec3 L, in vec3 N, in vec3 O ) // pour la lumière j
{

    float NdotL = max( 0.0, dot( N, L ) );

    vec4 frontColor = FrontMaterial.ambient * LightSource.ambient[j];
    float NdotHV;
    if(NdotL > 0){
        if(utiliseBlinn){
            NdotHV = pow(max(0.0, dot(normalize(L + O), N)), FrontMaterial.shininess);
        } else {
            NdotHV = pow(max(0.0, dot(reflect(-L, N), O)), FrontMaterial.shininess);
        }
        frontColor += FrontMaterial.diffuse * LightSource.diffuse[j] * NdotL + FrontMaterial.specular * LightSource.specular[j] * NdotHV;
    }
    return frontColor;

}

float interpole( float v0, float v1, float v2, float v3 )
{
    // mix( x, y, f ) = x * (1-f) + y * f.
    float v01 = mix( v0, v1, gl_TessCoord.x );
    float v32 = mix( v3, v2, gl_TessCoord.x );
    return mix( v01, v32, gl_TessCoord.y );
}

vec2 interpole( vec2 v0, vec2 v1, vec2 v2, vec2 v3 )
{
    // mix( x, y, f ) = x * (1-f) + y * f.
    vec2 v01 = mix( v0, v1, gl_TessCoord.x );
    vec2 v32 = mix( v3, v2, gl_TessCoord.x );
    return mix( v01, v32, gl_TessCoord.y );
}

vec3 interpole( vec3 v0, vec3 v1, vec3 v2, vec3 v3 )
{
    // mix( x, y, f ) = x * (1-f) + y * f.
    vec3 v01 = mix( v0, v1, gl_TessCoord.x );
    vec3 v32 = mix( v3, v2, gl_TessCoord.x );
    return mix( v01, v32, gl_TessCoord.y );
}

vec4 interpole( vec4 v0, vec4 v1, vec4 v2, vec4 v3 )
{
    // mix( x, y, f ) = x * (1-f) + y * f.
    vec4 v01 = mix( v0, v1, gl_TessCoord.x );
    vec4 v32 = mix( v3, v2, gl_TessCoord.x );
    return mix( v01, v32, gl_TessCoord.y );
}

void main()
{
    gl_Position = matrProj * interpole(gl_in[0].gl_Position, gl_in[1].gl_Position, gl_in[3].gl_Position, gl_in[2].gl_Position );

    vec3 pos = interpole(gl_in[0].gl_Position, gl_in[1].gl_Position, gl_in[3].gl_Position, gl_in[2].gl_Position).xyz;

    AttribsOut.TexCoord = interpole(AttribsIn[0].TexCoord, AttribsIn[1].TexCoord, AttribsIn[3].TexCoord, AttribsIn[2].TexCoord);

        // transformation standard du sommet
        
        for(int i = 0; i < 3; i++){
            AttribsOut.L[i] = (matrVisu * LightSource.position[i] / LightSource.position[i].w).xyz;
            AttribsOut.L[i] = normalize(AttribsOut.L[i] - pos);
        }

        // couleur du sommet

        AttribsOut.N = interpole(AttribsIn[0].N, AttribsIn[1].N, AttribsIn[3].N, AttribsIn[2].N);
        AttribsOut.N = normalize(matrNormale * AttribsOut.N);
        
        AttribsOut.O = normalize(-pos);

        if(typeIllumination == 0){
            AttribsOut.couleur = FrontMaterial.ambient * LightModel.ambient + FrontMaterial.emission;

            for(int j = 0; j < 3; j++){
                AttribsOut.couleur += calculerReflexion( j, AttribsOut.L[j], AttribsOut.N, AttribsOut.O );
            }
        } else {
            AttribsOut.couleur = interpole(AttribsIn[0].couleur, AttribsIn[1].couleur, AttribsIn[3].couleur, AttribsIn[2].couleur);
        }

}
