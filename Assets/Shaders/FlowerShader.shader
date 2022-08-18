Shader "Unlit/FlowerShader"
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
            #define PI 3.14159265359
// お決まり疑似乱数

            float rand(float2 uv)
            {
            return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float frequency(float2 st, float n)
            {
//pで各ピクセルが自分が入っているマスの真ん中へ移動させる

                float p = (floor(st * n) + 0.5) / n;
                return 3.5 * length(0.5 - p);
             }
// hue値をrgb変換メソッド

            float3 hue_to_rgb(float h)
            {
                h = frac(h) * 6 - 2;
                return saturate(float3(abs(h - 1) - 1, 2 - abs(h), 2 - abs(h - 2)));
            }

            float wave(float freq)
            {
                // freqが波のアニメーションのタイミング

                return (1 + sin(-_Time.y * 2 + freq)) * 0.5;
            }
//回転軸を真ん中にして回転行列を乗算する

            float2 rotate(float2 st, float angle)
            {
                st -= 0.5;
                st = mul(float2x2(cos(angle), -sin(angle),
                          sin(angle),  cos(angle)), st);
                st += 0.5;
                return st;
            }
// 切り落とすお決まりのパターン

            float draw_circle(float2 st, float size)
            {
                return step(length(0.5 - st), size);
            }

            float4 draw_flower(float2 uv, float n)
            {
// 極座標に変換する frac(uv * n)はマスごとの座標にして正規化している

                float2 st = 0.5 - frac(uv * n);
// 各マスで制御する

                float size = wave(frequency(uv, n)) * 0.8;
// 原点からの距を出す

                float r = length(st) * 2;
// atan2は-PI~PIが出てそれをTimeで時間で変化させる

                float a = atan2(st.y, st.x) + _Time.y / 2;

                float f = (abs(cos(a * 6)) + 0.4) * pow(size, 3) * 1.4;
                float4 color = 0;
// 花弁

                float petal = 1 - smoothstep(f, f + 0.02, r);
// colorは乱数でよしなに出す

                color = lerp(color, float4(hue_to_rgb(rand(floor(uv * n) / n)), 1), petal);
                float cap = draw_circle(st + 0.5, pow(size, 2) * 0.15);
                return lerp(color, float4(0.99, 0.78, 0, 1), cap);
            }


            fixed4 frag (v2f_img i) : SV_Target
            {
// アスペクト比の調整

                i.uv = screen_aspect(i.uv);
// 90度ずつ回転する

                float2 st = rotate(i.uv, 0.25 * PI);
// 各マスで個別に制御するためのwave

                float size = wave(frequency(st, 10));
// 背景の円を書く

                float4 color = draw_circle(frac(st * 20), 0.35 * size) * 0.15;
// 一列に5個の花を描く
                float4 flower = draw_flower(st, 5);
// 線形補完

                return lerp(color, flower, flower.w);
            }
            ENDCG
        }
    }
}
