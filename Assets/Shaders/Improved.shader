Shader "Sample/ImprovedNoise"
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

            float dotGradient(float2 seeds, float3 f)
            {
                switch (floor(lerp(0, 12, random(seeds))))
                {
                    case  0: return  f.x + f.y; // ( 1,  1,  0)
                    case  1: return -f.x + f.y; // (-1,  1,  0)
                    case  2: return  f.x - f.y; // ( 1, -1,  0)
                    case  3: return -f.x - f.y; // (-1, -1,  0)
                    case  4: return  f.x + f.z; // ( 1,  0,  1)
                    case  5: return -f.x + f.z; // (-1,  0,  1)
                    case  6: return  f.x - f.z; // ( 1,  0, -1)
                    case  7: return -f.x - f.z; // (-1,  0, -1)
                    case  8: return  f.y + f.z; // ( 0,  1,  1)
                    case  9: return -f.y + f.z; // ( 0, -1,  1)
                    case 10: return  f.y - f.z; // ( 0,  1, -1)
                    case 11: return -f.y - f.z; // ( 0, -1, -1)
                }

                return 0;
            }

            float improvedNoise(float3 seeds)
            {
                float3 i = floor(seeds);
                float3 f = frac (seeds);

                float2 i00 = i + float2(0, 0);
                float2 i10 = i + float2(1, 0);
                float2 i01 = i + float2(0, 1);
                float2 i11 = i + float2(1, 1);

                float3 f000 = float3(f.x,     f.y,     f.z);
                float3 f100 = float3(f.x - 1, f.y,     f.z);
                float3 f010 = float3(f.x,     f.y - 1, f.z);
                float3 f110 = float3(f.x - 1, f.y - 1, f.z);
                float3 f001 = float3(f.x,     f.y,     f.z - 1);
                float3 f101 = float3(f.x - 1, f.y,     f.z - 1);
                float3 f011 = float3(f.x,     f.y - 1, f.z - 1);
                float3 f111 = float3(f.x - 1, f.y - 1, f.z - 1);

                float2 v000 = dotGradient(i00, f000);
                float2 v100 = dotGradient(i10, f100);
                float2 v010 = dotGradient(i01, f010);
                float2 v110 = dotGradient(i11, f110);

                float2 v001 = dotGradient(i00 + 1, f001);
                float2 v101 = dotGradient(i10 + 1, f101);
                float2 v011 = dotGradient(i01 + 1, f011);
                float2 v111 = dotGradient(i11 + 1, f111);

                float3 p = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

                float v000v100 = lerp(v000, v100, p.x);
                float v010v110 = lerp(v010, v110, p.x);
                float v001v101 = lerp(v001, v101, p.x);
                float v011v111 = lerp(v011, v111, p.x);

                float v000v100v010v110 = lerp(v000v100, v010v110, p.y);
                float v001v101v011v111 = lerp(v001v101, v011v111, p.y);

                float v = lerp(v000v100v010v110,
                               v001v101v011v111, p.z);

                return v * 0.5 + 0.5;
            }

            float _NoiseScale;
            float _NoiseAspect;

            float4 frag(v2f_img i) : SV_Target
            {
                i.uv   *= _NoiseScale;
                i.uv.x *= _NoiseAspect;

                return improvedNoise(float3(i.uv, 0));
            }

            ENDCG
        }
    }
}