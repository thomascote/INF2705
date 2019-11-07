layout(quads) in;

in Attribs {
    vec4 couleur;
} AttribsIn[];

out Attribs {
    vec4 couleur;
} AttribsOut;

vec4 interpole( vec4 v0, vec4 v1, vec4 v2, vec4 v3 )
{
    // mix( x, y, f ) = x * (1-f) + y * f.
    vec4 v01 = mix( v0, v1, gl_TessCoord.x );
    vec4 v32 = mix( v3, v2, gl_TessCoord.x );
    return mix( v01, v32, gl_TessCoord.y );
}

void main()
{
    gl_Position = interpole( gl_in[0].gl_Position, gl_in[1].gl_Position, gl_in[2].gl_Position, gl_in[3].gl_Position );
    // gl_Position.z = 1.0 - length( gl_Position.xy );
    // gl_Position.xyz = normalize( gl_Position.xyz );
    AttribsOut.couleur = interpole( AttribsIn[0].couleur, AttribsIn[1].couleur, AttribsIn[2].couleur, AttribsIn[3].couleur );
}
