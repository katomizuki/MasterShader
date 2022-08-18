Shader "Sample/WhiteNoise"
{
    Properties { }
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex   vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Random.cginc"

            float whiteNoise(float2 seeds)
            {
                return random(seeds);
            }

            float4 frag(v2f_img i) : SV_Target
            {
                return whiteNoise(i.uv);
            }

            ENDCG
        }
    }
}