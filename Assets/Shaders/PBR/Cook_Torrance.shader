Shader "Unlit/Cook_Torrance"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Ambient("Ambient", Range(0,1))= 0
        _SpecColor("Specular Color", Color) = (0.872, 0.866, 0.370, 1.0)
        _Roughness("Roughness", Range(0.0000001, 1)) = 0.5
        _FresnelEffect("FresnelEffect", Float) = 20.0
    }
    SubShader
    {
        Tags { "RenderType"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _LightColor0;
            float _Ambient;
            float4 _SpecColor;
            float _Roughness;
            float _FresnelEffect;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = worldNormal;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.worldNormal);
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 halfDir = normalize(lightDir + viewDir);

                // 各ベクトルの角度量
                float NdotV = saturate(dot(normal,viewDir));
                float NdotH = saturate(dot(normal,halfDir));
                float VdotH = saturate(dot(viewDir, halfDir));
                float NdotL = saturate(dot(normal, lightDir));
                float LdotH = saturate(dot(lightDir, halfDir));

                float4 tex = tex2D(_MainTex, i.uv);
                // 拡散色の決定
                float diffusePower = max(_Ambient, NdotL);
                float4 diffuse = diffusePower * tex * _LightColor0;

                // ベックマン分布関数
                float m = _Roughness * _Roughness;
                float r1 = 1.0 / ( 4.0 * m * pow(NdotH + 0.00001f, 4.0));
                float r2 = (NdotH * NdotH - 1.0) / (m * NdotH * NdotH + 0.00001f);
                float D = r1 * exp(r2);

                // 幾何減衰
                float g1 = 2 * NdotH * NdotV / VdotH;
                float g2 = 2 * NdotH * NdotL / VdotH;
                float G = min(1.0, min(g1, g2));

                // フレネル項
            float n = _FresnelEffect;// 複素屈折率の実部
            float g = sqrt(n * n + LdotH * LdotH - 1);
            float gpc = g + LdotH;
            float gnc = g - LdotH;
            float cgpc = LdotH * gpc - 1;
            float cgnc = LdotH * gnc + 1;
            float F = 0.5f * gnc * gnc * (1 + cgpc * cgpc / (cgnc * cgnc) ) / (gpc
* gpc);
            half BRDF = (F * D * G) / (NdotV * NdotL * 4.0 + 0.0001f);
            half3 finalValue = BRDF * _SpecColor * _LightColor0;
            fixed4 col = diffuse + float4(finalValue, 1.0);
            return col;
            }
            ENDCG
        }
    }
}
