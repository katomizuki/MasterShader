Shader "Unlit/EmissionShader"
{
    Properties
    {
        [Header(Diffuse)]
        _Color("Color",Color) = (1,1,1,1)
        _Diffuse("Diffuse value",Range(0,1)) = 1.0
        [Header(Emission)]
        _MainTex("Emissive Map",2D) = "white"  {}
        [HDR] _EmissionColor ("EmissionColor", Color) = (0,0,0)
        _Threshold("Threshold", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"= "ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 col : COLOR0;
            };

            fixed4 _Color;
            fixed4 _LightColor0;
            float _Diffuse;

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                // 拡散反射
                float NdotL = max(0.0, dot(worldNormal, lightDir));
                fixed4 diff = NdotL * _Color * _LightColor0 * _Diffuse;
                o.col = diff;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            float _EmissionColor;
            float _Threshold;

            fixed4 frag (v2f i) : SV_Target
            {
                // 光の排出量を乗算する(光らせたい部分）
                fixed3 emi = tex2D(_MainTex, i.uv).r * _EmissionColor.rgb * _Threshold;
                // それをrgbに加算する
                i.col.rgb += emi;
                return i.col;
            }
            ENDCG
        }
    }
}
