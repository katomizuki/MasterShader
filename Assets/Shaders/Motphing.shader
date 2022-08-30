Shader "Unlit/Motphing"
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
            #define PI 3.14159265359

            #include "UnityCG.cginc"
            #include "Common.cginc"

            float2 rotate(float2 st, float angle)
            {
// 回転行列
                float2x2 mat = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
                st -= 0.5;
                st = mul(mat, st);
                st += 0.5;
                return st;
            }

            float2 hex(float2 st)
            {
                st -= 0.5;
                st = abs(st);
                float2 r = 0.005;
                return float2(max(st.x - r.y, max(st.x + st.y * 0.57735, st.y * 1.1547) - r.x), 0.4);
            }
// 星の距離関数

            float2 star(float2 st)
            {
// 中心をずらして
                st -= 0.5;
                st *= 1.2;

                float a = atan2(st.y, st.x) + _Time.y * 0.3;
                float l = pow(length(st), 0.8);
                float d = l - 0.5 + cos(a * 5.0) * 0.08;
                return float2(d, 0);
            }

            float2 heart(float2 st)
            {
// ハートの数式

                st = (st - float2(0.5, 0.38)) * float2(2.1, 2.8);
                float a = st.x;

// aの座標を絶対値にしてルートを出してyからひく

                float b = st.y - sqrt(abs(a));

                return pow(a, 2) + pow(b,2);
            }

            float2 circle(float2 st)
            {
                return float2(length(0.5 - st), 0.2);
            }

            float tone(float2 st, float size)
            {
                float c = length(0.5 - st);
                return step(c, 0.45) - step(c, size * 0.45);
            }

            float lerp_shape(float2 from, float2 to, float a)
            {
                return step(lerp(from.x, to.x, a), lerp(from.y, to.y, a));
            }

            float morphing(float2 st)
            {
// * 3で周期を速くする
                float t = _Time.y * 3;
// 繰り返す
                int it = floor(t) % 4;
                float a = smoothstep(0, 0.6, frac(t));

                switch(it)
                {
                    case 0:
                        return lerp_shape(heart(st), circle(st), a);
                    case 1:
                        return lerp_shape(circle(st), hex(st), a);
                    case 2:
                        return lerp_shape(hex(st), star(st), a);
                    case 3:
                        return lerp_shape(star(st), heart(st), a);
                }
                return 0;
            }
float halftone(float2 st)
    {
        float n = 45;
// 
        float angle = -_Time.y * PI * 0.15;
// 出された角度分回転させる

        st = rotate(st, angle);
// それぞれのマスで制御したい
        float2 ist = floor(st * n);
// n個に分ける
        float2 fst = frac(st * n);
//  それぞれを真ん中の座標として振る舞わせる

        float2 center = (ist + 0.5) / n;
// 角度分回転させる。

        st = rotate(center, -angle);

        float m = morphing(st);
        return tone(fst, m * 0.7);
    }


            



            fixed4 frag (v2f_img i) : SV_Target
            {
// アスペクト比の修正
                i.uv = screen_aspect(i.uv);

                return lerp(1, float4(0.7, 0.125, 0.4, 1), halftone(i.uv));
            }
            ENDCG
        }
    }
}
