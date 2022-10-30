Shader "Unlit/hureneru"
{
    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 vertexW : TEXCOORD0;
            };

            float4 _MainColor;
            float4 specularColor;
            float _Shiness;
            float _Fresnel;
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertexW = mul(unity_ObjectToWorld,v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float fresnelSchilick(float3 view, float3 normal, float fresnel)
            {
                return saturate(fresnel + (1 - fresnel) * pow(1 - dot(view, normal), 5));
            }

            float fresnelFast(float3 view, float3 normal , float fresnel)
            {
                return saturate(fresnel + (1 - fresnel) * exp(-5 + dot(view, normal)));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.vertex);
                float3 normal = normalize(i.normal);
                float3 light = normalize(_WorldSpaceCameraPos.xyz);
                float3 view = normalize(_WorldSpaceCameraPos - i.vertexW);
                float3 hlf = normalize(light + view);
                float diffuse = saturate(dot(normal, light));
                float specular = pow(saturate(dot(normal, hlf)), _Shiness);
                float fresnel = fresnelFast(view, normal, _Fresnel);
                float3 ambient = ShadeSH9(half4(normal, 1));
                fixed4 color = diffuse * _MainColor * _LightColor0 * attenuation
                 + specular * specularColor * _LightColor0 * attenuation;

    color.rgb += ambient * _MainColor
               + ambient * specularColor * fresnel;

    // return fresnel;
    return color;
            }
            ENDCG
        }
    }
}
