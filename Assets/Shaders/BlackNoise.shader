Shader "Sample/BlockNoise"
{
    Properties
    {
        _NoiseScale ("Noise Scale",  Range(0, 50)) = 10
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

            float blockNoise(float2 seeds)
            {
                return random(floor(seeds));
            }

            float _NoiseScale;

            float4 frag(v2f_img i) : SV_Target
            {
                if (random2(i.uv).x < 0 || random2(i.uv).y < 0)
                {
                    return float4(1, 0, 0, 1);
                }

                return blockNoise(i.uv * _NoiseScale);
            }

            ENDCG
        }
    }
}