Shader "Unlit/Lattices2Shader"
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
                float mat = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
                st -= 0.5;
                st = mul(mat, st);
                return st;
            }

            float box(float2 st, float t)
            {
                st = rotate(st, t * 2.05 * PI / 4);
        
                float size = t * 1.42;
//size分切り取って四角形を作っているだけ

                st = step(size, st) * step(size, 1.0 - st);
                return st.x * st.y;
            }

            float lattice(float2 st, float n)
            {
                float2 ist = floor(st * n);
                float2 center = (ist + 0.5) / n;
                float freq = 2.5 * length(0.5 - center);
// 時間に乗算しているのでアニメーションを早くしている

                float t = sin(-_Time.y + freq) * 0.5;
// n回繰り返すための正規化

                return box(frac(st * n), t);
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
                i.uv = screen_aspect(i.uv);
                i.uv = rotate(i.uv, PI / 4);
                return float4(lattice(i.uv, 3),lattice(i.uv, 5),lattice(i.uv, 30), 1);
            }
            ENDCG
        }
    }
}
