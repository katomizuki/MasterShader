Shader "Unlit/snow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SnowPileValue("SnowPileValue", Range(0, 3)) = 0.0
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
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _SnowPileValue;

            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // 法線
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // fixed3は雪の降る方向
                // これが位置に近いほど上を向いているということになる。
                float d = dot(i.normal, fixed3(0, 1, 0));
                // テクスチャマッピング
                fixed4 col = tex2D(_MainTex, i.uv);
                // 白
                fixed4 white = fixed4(1,1,1,1);
                // lerpにかけて雪の値を計算 snowPileValueはスケーラー
                col = lerp(col, white, d * _SnowPileValue);
                return col;
            }
            ENDCG
        }
        
        Pass {
            Name "CastShadow"
            Tags { "LightMode"="ShadowCaster"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
// シャドウマッピングする用のpragma
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            struct v2f
            {
                // pos : SV_POSITIONのシャドウマッピングよう
               V2F_SHADOW_CASTER; 
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                // 
                TRANSFER_SHADOW_CASTER(o);
                return o;
            }

            float4 frag(v2f i )
            {
                // 視点空間の深度を表している。
                // 内部ではポイントライトが当たった場合　深度値を出力してくれるっぽいが、SVDepthの値を出力したいのでSVTartgetがどんな値でも良いという前提で0を返す
// 光源からのオブジェクトの距離ベクトルを正規化して、　深度変換ようのバイアスなるものをかけている。この計算で0~1に深度がまとまる
                SHADOW_CASTER_FRAGMENT(i)
                // UNITY_OUTPU
            }
            ENDCG
            }
    }
}
