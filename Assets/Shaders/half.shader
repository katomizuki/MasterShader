Shader "Unlit/half"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 vertexW : TEXCOORD1;
            };

            float4 _MainColor;
            float4 _SpecularColor;
            float _Shiness;
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.vertexW = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               // 減衰をしめしている。 
    UNITY_LIGHT_ATTENUATION(attenuation, i, i.vertexW)
                float3 normal = normalize(i.normal);
                float3 light = normalize(_WorldSpaceLightPos0.xyz);
                float3 view = normalize(_WorldSpaceCameraPos - i.vertexW);
                float3 hlf = normalize(light + view);
                float diffuse = saturate(dot(normal, light));
                float specular = pow(saturate(dot(normal,hlf)),_Shiness);
                float3 ambient = ShadeSH9(half4(normal, 1));
                
                
                fixed4 color = diffuse * _MainColor * _LightColor0 * attenuation
                 + specular * _SpecularColor * _LightColor0 * attenuation;

    color.rgb += ambient * _MainColor;

    return color;
            }
            ENDCG
        }
    }
}
