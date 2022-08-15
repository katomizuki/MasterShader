Shader "Unlit/CircleShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
       

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag


            #include "UnityCG.cginc"
            #include "Common.cginc"

// 色相からrbgに変換

            float3 hue_to_rgb(float h)
            {
                h = frac(h) * 6 - 2;
                return saturate(float3(abs(h - 1) - 1, 2 - abs(h), 2 - abs(h -2)));
            }

            float circle(float2 st, float size)
            {
// 0を閾値として0か1 × smoothstepで開始を0としてsizeの大きさまで段々と中央からの離れるたびに
               return step(0, size) * (1 - smoothstep(0, size, length(0.5 - st)));
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
// アスペクト比を揃える
                i.uv = screen_aspect(i.uv);
                float n = 13;
// 各マスを制御したいのでfloor(i.uv * n)  真ん中の座標にある振る舞いをする
//　ist + 0.5->真ん中の座標に変換し、nで割って正規化する
// 13マスに分ける

                float2 ist = floor(i.uv * n);
                float freq = 7 * length(0.5 - (ist + 0.5) / n);
// 時間によって歪ませる。

                float t = sin(-_Time.y * 2 + freq) * 0.5;
        // 画面の真ん中に原点がある状態にする
                i.uv -= 0.5;
// そこからtをかける

                i.uv *= t;
// 戻す
                i.uv += 0.5;
        // 半径

                float a = circle(frac(i.uv * n), t);
// 色をかけて色を変える。
                return a * float4(hue_to_rgb(0.23 + freq * 0.16), 1);
            }
            ENDCG
        }
    }
}
