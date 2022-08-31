Shader "Unlit/BasicShader"
{
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            
// セマンティクス
            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

// vertexシェーダー
            v2f vert (appdata_base v)
            {
                v2f o;
// モデル座標 ワールド座標 ビュー座標 クリップ座標
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return half4(1, 0, 0, 1);
            }
            ENDCG
        }
    }
}
