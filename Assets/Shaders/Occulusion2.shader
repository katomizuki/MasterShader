Shader "Unlit/Occulusion2"
{
    SubShader
    {
        Tags { "Queue"="geometry-1" }
        //フラグメントシェーダーのAlpha値が0の場合、最終的な描画結果はカラーバッファに既に書き込まれている値になる
        //計算式 → 1 × フラグメントシェーダーの出力(one) + (1 - フラグメントシェーダーの出力するアルファ値(OneMinusSrcAlpha) ×　カラーバッファに既に書き込まれている値
        //結果 → 1 × 0 + (1 - 0) ×　カラーバッファに既に書き込まれている値 = カラーバッファに既に書き込まれている値　つまりそのまま

        Blend One OneMinusSrcAlpha
        //フラグメントシェーダーのAlpha値が1の場合、最終的な描画結果はカラーバッファに既に書き込まれている値になる
        //計算式 → 0 × フラグメントシェーダーの出力 + フラグメントシェーダーの出力するアルファ値 ×　カラーバッファに既に書き込まれている値
        //結果 → 0 × 1 + 1 ×　カラーバッファに既に書き込まれている値 = カラーバッファに既に書き込まれている値　つまりそのまま
        //Blend Zero SrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return 0;
            }
            ENDCG
        }
    }
}
