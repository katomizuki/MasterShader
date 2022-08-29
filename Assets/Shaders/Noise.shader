Shader "Unlit/Noise"
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

            float2 random2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)),
                    dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
                i.uv = screen_aspect(i.uv);
                float2 st = i.uv;
                st *= 4.0;

                float2 ist = floor(st);
                float2 fst = frac(st);

                float distance = 5;

                for(int y = -1; y <= 1; y++)
                {
                  for(int x = -1; x <= 1; x++)
                    {
// マスに区切った時に隣の座標を見てくる
                        float2 neighbor = float2(x, y);
// // 
                        float2 p = 0.5 + 0.5 * sin(_Time.y + 6.2831 * random2(ist + neighbor));

                        float2 diff = neighbor + p - fst;
                        distance = min(distance, distance * length(diff) * length(diff));
                    }
                }
            return float4(step(0.1, distance) * 0.5,
                      step(0.2, distance) * 0.5,
                      step(0.5, distance) * 0.5,
                      0);
            }
            ENDCG



        }
    }
}
