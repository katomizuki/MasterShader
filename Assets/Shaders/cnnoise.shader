Shader "Unlit/cnnoise"
{
    Properties
    {
        _NoiseScale("Noise Scale", Range(0, 50)) = 10
        _NoiseAspect("Noise Aspect", Range(0, 10)) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Random.cginc"

            float _NoiseScale;
            float _NoiseAspect;

            float cellularNoise(float2 seeds)
            {
                // 整数部分を切り取り
                float2 i = floor(seeds);
                // 小数部分を切り取り
                float2 f = frac(seeds);
                // 最小距離を3と仮定して　
                float minDistance = 3;
                // 縦にloop
                for(int y = -1; y <= 1; y++)
                {
                    // 横にloop=>すべての方向 上下左右斜めのマスを見にいくから
                    for (int x = -1; x <= 1; x++)
                    {
                        // その座標を取得(-1 ~ 1, -1 ~ 1)
                        float2 neighbor = float2(x,y);
                        //　そこから任意の点座標を出す。
                        float2 p = random2(i + neighbor);
                        
                        minDistance = min(minDistance, length(neighbor + p - f));
                    }
                }
                return minDistance;
            }
            fixed4 frag (v2f_img i) : SV_Target
            {
                i.uv *= _NoiseScale;
                i.uv.x *= _NoiseAspect;
                return cellularNoise(i.uv);
            }
            ENDCG
        }
    }
}
