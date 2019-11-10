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

layout(location=0) in vec4 Vertex;
layout(location=2) in vec3 Normal;
layout(location=3) in vec4 Color;
layout(location=8) in vec4 TexCoord;

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

void main( void )
{
    // transformation standard du sommet
    gl_Position = matrProj * matrVisu * matrModel * Vertex;

    vec3 pos = ( matrVisu * matrModel * Vertex ).xyz;

    AttribsOut.TexCoord = TexCoord.st;
    
    for(int i = 0; i < 3; i++){
        AttribsOut.L[i] = (matrVisu * LightSource.position[i] / LightSource.position[i].w).xyz;
        AttribsOut.L[i] = normalize(AttribsOut.L[i] - pos);
    }

    AttribsOut.O = normalize(-pos);
    AttribsOut.N = normalize(matrNormale * Normal);

    // couleur du sommet
    if(typeIllumination == 0){
        AttribsOut.couleur = FrontMaterial.ambient * LightModel.ambient + FrontMaterial.emission;

        for(int j = 0; j < 3; j++){
            AttribsOut.couleur += calculerReflexion( j, AttribsOut.L[j], AttribsOut.N, AttribsOut.O );
        }
    } else {
        AttribsOut.couleur = Color;
    }
    
    //AttribsOut.couleur = Color; // à modifier!
}
