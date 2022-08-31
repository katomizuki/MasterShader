Shader "Unlit/DomainWarpShading"
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

            float random(float2 st)
            {
             return frac(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float noise(float2 st)
            {
                //　それぞれをマスで制御するために小数点を切る

                float2 ist = floor(st);
// 少数部分を返す。マスを分けるために

                float2 fst = frac(st);

                float a = random(ist);
                float b = random(ist + float2(1.0, 0.0));
                float c = random(ist + float2(0.0, 1.0));
                float d = random(ist + float2(1.0, 1.0));

                float2 u = fst * fst * (3.0 - 2.0 * fst);
// 割合によってブレンドさせる。

                return lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
            }

            float fbm(float2 st)
            {
                float v = 0.0;
                float a = 0.5;
                float2 shift = 100.0;
// 回転行列を生成

                float2x2 rotate = float2x2(cos(0.5), sin(0.5), -sin(0.5), cos(0.5));

                for (int i = 0; i < 7; ++i)
                {
// aにNoiseをかけてたす

                    v += a * noise(st);
// 実際に回転させる
                    st = mul(rotate, st) * 2.0 + shift;
                    a *= 0.5;
                }
                return v;
            }



            fixed4 frag (v2f_img i) : SV_Target
            {
                i.uv = screen_aspect(i.uv);
                float t = _Time.y;
                float2 st = i.uv;
                float2 q = 0;
                q.x = fbm(st + 0.0 * t);
                q.y = fbm(st + 1);
                float2 r = 0;
                r.x = fbm(st + 2.0 * q + float2(1.7, 9.2) + 0.15 * t);
                r.y = fbm(st + 2.0 * q + float2(8.3, 2.8) + 0.126 * t);

                float f = fbm(st + r);
                float3 color = 0.0;

                color = lerp(float3(0.1, 0.62, 0.67),
                     float3(0.67, 0.67, 0.5),
                     saturate(f * f * 4.0));

                color = lerp(color,
                     float3(0, 0, 0.16),
                     saturate(length(q)));

                color = lerp(color,
                     float3(0.1, 1, 0.07),
                     saturate(length(r.x)));

                return float4((f * f * f + 0.6 * f * f + 0.5 * f) * color, 1.0);
            }
            ENDCG
        }
    }
}
