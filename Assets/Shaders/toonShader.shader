Shader "Unlit/toonShader"
{
    Properties
    {
        _MainTexture ("Main Texture", 2D) = "white" {}
        _ShadowTexture ("Shadow Texture", 2D) = "white" {}
        _Strength("Strength",Range(0,1)) = 0.5
    }
    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTexture;
            sampler2D _ShadowTexture;
            float _Strength;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                 //1つ目のライトのベクトルを正規化
                float3 l = normalize(_WorldSpaceLightPos0.xyz);
                
                //ワールド座標系の法線を正規化
                float3 n = normalize(i.worldNormal);
                
                //内積でLerpの補間値を計算　0以下の場合のみ補間値を利用して閾値を出す
                float interpolation = step(dot(n, l),0);
                
                //絶対値で正数にすることで影の領域を塗分ける
                float2 absD = abs(dot(n, l));
                
                //影の領域のテクスチャをサンプリング
                float3 shadowColor = tex2D(_ShadowTexture, absD).rgb;
                
                //メインのテクスチャをサンプリング
                float3 mainColor = tex2D(_MainTexture, i.uv).rgb;
                
                //補間値を用いて色を塗分け　影の強さ(影テクスチャーの濃さ)もここで調整
                float3 finalColor = lerp(mainColor, shadowColor * (1 - _Strength) * mainColor,interpolation);
                return float4(finalColor,1);
            }
            ENDCG
        }
    }
}
