Shader "Sample/Voronoi"
{
    Properties
    {
        _NoiseScale  ("Noise Scale",  Range(0, 50)) = 10
        _NoiseAspect ("Noise Aspect", Range(0, 10)) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex   vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Random.cginc"

            float2 voronoi(float2 seeds)
            {
                float2 i = floor(seeds);
                float2 f = frac(seeds);

                float  minDistance = 5;
                float2 minP = float2(0, 0);

                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 neighbor = float2(x, y);

                        float2 p = random2(i + neighbor);

                        float distance = length(neighbor + p - f);

                        bool update = minDistance > distance;

                        minDistance = update ? distance : minDistance;
                        minP        = update ?        p :        minP;
                    }
                }

                return minP;
            }

            float _NoiseScale;
            float _NoiseAspect;

            float4 frag(v2f_img i) : SV_Target
            {
                i.uv   *= _NoiseScale;
                i.uv.x *= _NoiseAspect;

                return float4(voronoi(i.uv), 1, 1);
            }

            ENDCG
        }
    }
}