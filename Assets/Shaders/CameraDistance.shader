Shader "Unlit/CameraDistance"
{
    Properties
    {
         [NoScaleOffset] _NearTex ("NearTexture", 2D) = "white" {}
        //テクスチャー(オフセットの設定なし)
        [NoScaleOffset] _FarTex ("FarTexture", 2D) = "white" {}
    }
    SubShader
    {
        // 透明度に関する設定 透明関連にしたい場合はTransparent、それ以外だとOpaqueくらいに覚えておく
        Tags { "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Common.cginc"


            sampler2D _NearTex;
            sampler2D _FarTex;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex); // ローカル座標系をワールド座標系に変換
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // それぞれのテクスチャとuvからテクスチャのピクセルの色を取り出す
                float4 nearCol = tex2D(_NearTex, i.uv);
                float4 farCol = tex2D(_FarTex, i.uv);

                // カメラからオブジェクトの距離（長さ）を取得
                float cameraToObjeLength = length(_WorldSpaceCameraPos - i.worldPos);
                // Lengthが大きい分だけ数だけnearColの割合が大きくなる。
                fixed4 col = fixed4(lerp(nearCol, farCol, cameraToObjeLength * 0.05));
                // Alphaが0以下なら描画しない
                clip(col);
                // 最終的なピクセルの色を返す
                return col;
            }
            ENDCG
        }
    }
}
