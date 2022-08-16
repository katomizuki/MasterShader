#ifndef VARIOUSLIGHT_INCLUDED
#define VARIOUSLIGHT_INCLUDED

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

struct v2f
{
    float4 vertex  : SV_POSITION;
    float3 vertexW : TEXCOORD0;
    float3 normal  : TEXCOORD1;
};

float4 _MainColor;

v2f vert(appdata_base v)
{
    v2f o;

    o.vertex  = UnityObjectToClipPos(v.vertex);
    o.vertexW = mul(unity_ObjectToWorld, v.vertex);
    o.normal  = UnityObjectToWorldNormal(v.normal);

    return o;
}

fixed4 frag(v2f i) : SV_Target
{
    UNITY_LIGHT_ATTENUATION(attenuation, i, i.vertexW)

    float3 normal = normalize(i.normal);
    float3 light  = normalize(_WorldSpaceLightPos0.w == 0 ?
                              _WorldSpaceLightPos0.xyz :
                              _WorldSpaceLightPos0.xyz - i.vertexW);

    float  diffuse = saturate(dot(normal, light));
    float3 ambient = ShadeSH9(half4(normal, 1));

    fixed4 color = diffuse * _MainColor * _LightColor0 * attenuation;
           color.rgb += ambient * _MainColor;

    return color;
}

#endif // VARIOUSLIGHT_INCLUDED