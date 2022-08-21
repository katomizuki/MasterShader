Shader "Unlit/HexShader"
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

            float hex(float2 p, float2 r)
            {
            // 絶対値を出す
                p = abs(p);
                float k = max(p.x + p.y * 0.57735, p.y * 1.1547);
                return max(p.x - r.y, k - r.x);
            }

            float2 mod(float2 a, float2 b)
            {
                //あまりのmod 

                return a - b * floor(a / b);
            }

            float hex_grid(float2 st)
            {
                // 0.02を足す。
                st.x += 0.02;
                
                float2 g = float2(0.692, 0.4) * 0.5;
                float r = 0.005;
// p1時間によって動くようにする

                float2 p1 = mod(st, g) - g * 0.5;
                float2 p2 = mod(st + g * 0.5, g) - g * 0.5;
                
                return min(hex(p1, r), hex(p2, r));
            }

  
           

            fixed4 frag (v2f_img i) : SV_Target
            {
// アスペクト比の調整

                i.uv = screen_aspect(i.uv);
// 0.5 - i.uv で真ん中の座標に移動してそこからの距離とTimeを足して移動させる

                float d = -_Time.y + length(0.5 - i.uv);
// moduloとlengthで距離ごとの繰り返しを作成している（多分）

                float modulo = mod(d, 3.0);
                float m = min(modulo - 1.0, 1.0);
                float a = length(m);

                float h = hex_grid(i.uv) * a;
                float s = sin(h * 50);
//色を付けるやつで0,1で分岐している

                float abstep = abs(s);
                return float4(0.2, 1, 0.2, 1) * abstep;
            }
            ENDCG
        }
    }
}
