Shader "Unlit/Hex2Shader"
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

            float2 mod(float2 a, float2 b)
            {
                return a - b * floor(a / b);
            }

            float hex(float2 p, float2 r)
            {
            // 絶対値を出す これをすることによって第一象限
                p = abs(p);
                float k = max(p.x + p.y * 0.57735, p.y * 1.1547);
// 正六角形を利用して左右の辺までの長さが大きい方でクリッピングする必要がある。

                return max(p.x - r.y, k - r.x);
            }

            float hex_grid(float2 st)
            {
                st.x += 0.02;
                float2 g = float2(0.346, 0.2);
                float r = 0.005;
                //float h = ;
                float2 p1 = mod(st, g) - g * 0.5;
                float2 p2 = mod(st + g * 0.5, g) - g * 0.5;
                //return hex(p1,r);
                return min(hex(p2, r), hex(p1, r));
            }

            float swirl(float2 st) {
                float phi = atan2(st.y, st.x);
                return sin(length(st) * 8 + phi - _Time.y * 4) * 0.5 + 0.5;
            }



            fixed4 frag (v2f_img i) : SV_Target
            {
                i.uv = screen_aspect(i.uv - 0.5);
                float sw = swirl(i.uv - 0.5);
                float h = abs(0.5 + sin(hex_grid(i.uv) * 40 * sw));
                return 1 - float4(0, 1,1,1) * step(h, 0.12);
            }
            ENDCG
        }
    }
}
