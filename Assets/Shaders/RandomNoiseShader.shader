Shader "Unlit/RandomNoiseShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        CGPROGRAM
            #pragma surface surf Standard fullfowardshadows
            #pragma target 3.0

            sampler2D _MainTex;

            struct Input
            {
               float2 uv_MainTex; 
            };
            float random (fixed2 p)
            { 
                return frac(sin(dot(p, fixed2(12.9898,78.233))) * 43758.5453);
            }

            void surf (Input IN, inout SurfaceOutputStandard o)
            {
                float c = random(IN.uv_MainTex);
                o.Albedo = fixed4(c, c, c, 1);
            }
            ENDCG
        }
    FallBack "Diffuse"
}