Shader "Unlit/AmbientLightShader"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            float4 _MainColor;
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.normal);
                float3 light = normalize(_WorldSpaceLightPos0.xyz);

                float diffuse = saturate(dot(normal, light));
                // 環境光を参照する。(影の部分も明るくなる。）ShadeSH9(half4(normal,1))でも環境光を取得できる。
                float4 ambient = unity_AmbientSky;
                // 基本的にShadeSH9を作った方が良い。
                
                return diffuse * _MainColor * _LightColor0 + ambient * _MainColor;
            }
            ENDCG
        }
    }
}
