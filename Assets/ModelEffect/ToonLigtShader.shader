Shader "Unlit/ToonLigtShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShadowTexture("Shadow Texture", 2D) = "white" {}
        _Strength("Strenght", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            sampler2D _MainTexture;
            sampler2D _ShadowTexture;
            float _Strength;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // ライトのベクトルを正規化 
                float3 l = normalize(_WorldSpaceLightPos0.xyz);
                // 法線を正規化
                float3 n = normalize(i.worldNormal);
                // 反対側を向いていたら影を描画する必要なし。
                float interpolation = step(dot(n,l), 0);
                // 内積の絶対値をとる。今見ている頂点の明るさを見たいから
                float2 absD = abs(dot(n,l));
                // 影の領域テクスチャサンプリング
                float3 shadowColor = tex2D(_ShadowTexture, absD).rgb;
                // メインのテクスチャをサンプリング
                float3 mainColor = tex2D(_MainTexture, i.uv).rgb;
                // maincolorと影のカラーを補間値の閾値（0or1)で使い分ける
                float3 finalColor = lerp(mainColor, shadowColor * (1 - _Strength) * mainColor, interpolation);
                
                return float4(finalColor, 1);
            }
            ENDCG
        }
    }
}
