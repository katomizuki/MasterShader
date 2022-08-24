Shader "Unlit/LatticeShader"
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

            float2 rotate(float2 st, float angle)
            {
                // 回転行列
                float2x2 mat = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
                st -= 0.5;
                st = mul(mat, st);
                st += 0.5;
                return st;
            }

            float box(float2 st, float t)
            {
// tには0~0.5がランダムで入ってくる

                st = rotate(st, t * 2.05 * PI / 4);
// ｔ×sizeでサイズを出す

                float size = t * 1.42;
//下記二行でstepで四角を作成

                st = step(size, st) * step(size, 1.0 - st);
                return st.x * st.y;
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
                i.uv = screen_aspect(i.uv);
//                st = rotate(st, 0.5 * 2.05 * PI / 4);
//                st = step(0.1, st) * step(0.1, 1.0 - st);
  //              return st.x * st.y;
                // 座標を90度回転させる
                i.uv = rotate(i.uv, PI / 4);

               float n = 10;
// ピクセルを分ける
               float2 ist = floor(i.uv * n);
// 中心にもってくる

               float2 center = (ist + 0.5) / n;
               float freq = 2.5 * length(0.5 - center);
// freqはどれだけのアニメーションの頻度

               float t = sin(-_Time.y * 2 + freq) * 0.5;
//fracでかけて繰り返す
                return float4(box(frac(i.uv * 10), t), box(frac(i.uv * 18), t), box(frac(i.uv * 36), t), 1);
                //return box(frac(i.uv * n), t);
            }
            ENDCG
        }
    }
}
