Shader "Unlit/WhiteNAnimation"
{
    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"
            float random(float2 seeds)
{
    return frac(sin(dot(seeds, float2(12.9898, 78.233))) * 43758.5453);
}
            float whiteNoise(float2 seed)
            {
                return random(seed);
            }
            fixed4 frag (v2f_img i) : SV_Target
            {
               return whiteNoise(i.uv + _Time.x); 
            }
            ENDCG
        }
    }
}
