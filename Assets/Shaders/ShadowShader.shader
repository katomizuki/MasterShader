Shader "Unlit/ShadowShader"
{
    Properties
    {
        _MainColor("Main Color", Color) = (0, 0, 0, 1)
        _DiffuseShade("Diffuse Shade",Range(0, 1)) = 0.5
    }
    SubShader
    {
        // 影を受けるシェーダー
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // 影を受ける側のマルチコンパイルを行ってくれる。
            // 
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

            #include "UnityCG.cginc"
            // ライティングとシャドウ
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                // TransferShadow でposが決めうちになっているのでverteｘのままではだめ。
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                // 
                SHADOW_COORDS(1)
            };

            fixed4 _MainColor;
            float _DiffuseShade;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                // 
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 finalColor = fixed4(0, 0, 0, 1);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 N = normalize(i.worldNormal);
                fixed4 diffuseColor = max(0, dot(N, L) * _DiffuseShade + (1 - _DiffuseShade));
                finalColor = _MainColor * diffuseColor * _LightColor0;
                // 
                finalColor = SHADOW_ATTENUATION(i);
                return finalColor;
            }
            ENDCG
        }
// 影を落とすシェーダー
        Pass 
        {
            Tags 
            {
                // これによって周りのオブジェクトに影を落とし込むようにする。
                "LightMode"="ShadowCaster"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // 影を落とすために宣言する必要がある。
            // 影の落とし方（ライトの種類）に応じて部分的にシェーダーをコンパイル時に生成する　
            // コンパイル時にプリプロセッサディレクティブ（コンパイル前に判定する条件分岐）を使用する
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f 
            {
                // 同様
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                // 影落とすマクロ
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }

            float4 frag(v2f i)
            {
                // 同様
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
            }
        }
}
