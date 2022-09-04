Shader "Unlit/MaskSample"
{
    Properties
    {
        // テクスチャ(オフセット)
        [NoScaleOffset] _MainTex("Texture", 2D) = "white" {}
        [NoScaleOffset] _MaskTex("Texture (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Common.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;

            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // 3D空間->スクリーン座標変換。
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // マスク用画像のピクセルの色を計算
                fixed4 mask = tex2D(_MaskTex,i.uv);

                // 引数の値が0以下なら描画しない Alphaが0.5以下なら描画しない
                clip(mask.a - 0.5);
                // メイン画像のピクセルの色を計算
                fixed4 col = tex2D(_MainTex, i.uv);

                // メイン画像とマスク画像のピクセルの計算結果を掛け合わせる
                return col * mask;
            }
            ENDCG
        }
    }
}
