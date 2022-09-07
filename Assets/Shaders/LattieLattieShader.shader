Shader "Unlit/LattieLattieShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
            CGINCLUDE
            #include "UnityCG.cginc"
            #include "Common.cginc"
            #define PI 3.14159265359
            // ランダムな数
            float rand(float2 st)
            {
                return frac(sin(dot(st, float2(12.9889, 78.233))) * 43758.5453);
            }
// 回転行列をかける
            float2 rotate(float2 st, float angle)
            {
                float2x2 mat = float2x2(cos(angle), -sin(angle),
                                sin(angle), cos(angle));
                st -= 0.5;
                st = mul(mat, st);
                st += 0.5;
                return st;
            }
// 
            float box(float2 st, float t)
            {
                // 時間に2をスケーラーとして回転させる
                st = rotate(st, t * 2 * PI / 4);
                // 1.4はスケーラー
                float size = t * 1.4;
                // stには1か0が入る。 
                st = step(size, st) * step(size, 1.0 - st);
                // 1か0が返される。
                return st.x * st.y;
            }

            float lattice(float2 st, float n)
            {
                // 各マスを個別に制御したい
                float2 ist = floor(st * n);
                // 
                float freq = 3.5 * length(0.5 - (ist * 0.5) / n);
                float t = sin(rand(ist) * 2 * -_Time.y * 2 + freq) * 0.5;
                return box(frac(st * n), t);
            }
            
            float4 frag (v2f_img i) : SV_Target
            {
                i.uv = screen_aspect(i.uv);
                // 90度回転させる。
                i.uv = rotate(i.uv, PI / 4);
                // lattice
                return float4(lattice(i.uv, 7.5), lattice(i.uv, 15), 1, 1);
            }
    ENDCG
    
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            ENDCG
        }
    }
}
