Shader "Sample/ValueNoise"
{
    Properties
    {
        _NoiseScale  ("Noise Scale",  Range(0, 50)) = 10
        _NoiseAspect ("Noise Aspect", Range(0, 10)) =  1
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

            float valueNoise(float2 seeds)
            {
                float2 i = floor(seeds);
                float2 f = frac (seeds);

                float2 i00 = i + float2(0, 0);
                float2 i10 = i + float2(1, 0);
                float2 i01 = i + float2(0, 1);
                float2 i11 = i + float2(1, 1);

                float v00 = random(i00);
                float v10 = random(i10);
                float v01 = random(i01);
                float v11 = random(i11);

                float2 p = smoothstep(0, 1, f);
                    // p = f * f * (3 - 2 * f);
                    // p = lerp(0, 1, f);

                float v00v10 = lerp(v00, v10, p.x);
                float v01v11 = lerp(v01, v11, p.x);

                return lerp(v00v10, v01v11, p.y);
            }

            float _NoiseScale;
            float _NoiseAspect;

            float4 frag(v2f_img i) : SV_Target
            {
                i.uv   *= _NoiseScale;
                i.uv.x *= _NoiseAspect;

                return valueNoise(i.uv);
            }

            ENDCG
        }
    }
}