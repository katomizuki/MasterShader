Shader "Sample/FractalPerlinNoise"
{
    Properties
    {
                   _NoiseScale   ("Noise Scale",   Range(0, 50)) = 10
                   _NoiseAspect  ("Noise Aspect",  Range(0, 10)) =  1
        [IntRange] _NoiseOctaves ("Noise Octaves", Range(1,  5)) =  1
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

            float perlinNoise(float2 seeds)
            {
                float2 i = floor(seeds);
                float2 f = frac (seeds);

                float2 i00 = i + float2(0, 0);
                float2 i10 = i + float2(1, 0);
                float2 i01 = i + float2(0, 1);
                float2 i11 = i + float2(1, 1);

                float2 f00 = f - float2(0, 0);
                float2 f10 = f - float2(1, 0);
                float2 f01 = f - float2(0, 1);
                float2 f11 = f - float2(1, 1);

                float2 g00 = normalize(-1 + 2 * random2(i00));
                float2 g10 = normalize(-1 + 2 * random2(i10));
                float2 g01 = normalize(-1 + 2 * random2(i01));
                float2 g11 = normalize(-1 + 2 * random2(i11));

                float2 v00 = dot(g00, f00);
                float2 v10 = dot(g10, f10);
                float2 v01 = dot(g01, f01);
                float2 v11 = dot(g11, f11);

                float2 p = smoothstep(0, 1, f);

                float v00v10 = lerp(v00, v10, p.x);
                float v01v11 = lerp(v01, v11, p.x);

                return lerp(v00v10, v01v11, p.y) * 0.5 + 0.5;
            }

            float fractalPerlinNoise(float2 seeds, int octaves)
            {
                float value     = 0.0;
                float amplitude = 0.5;

                for (int i = 0; i < octaves; i++)
                {
                    value += perlinNoise(seeds) * amplitude;

                    seeds     *= 2.0;
                    amplitude *= 0.5;
                }

                return value;
            }

            float _NoiseScale;
            float _NoiseAspect;
            int   _NoiseOctaves;

            float4 frag(v2f_img i) : SV_Target
            {
                i.uv   *= _NoiseScale;
                i.uv.x *= _NoiseAspect;

                return fractalPerlinNoise(i.uv, _NoiseOctaves);
            }

            ENDCG
        }
    }
}