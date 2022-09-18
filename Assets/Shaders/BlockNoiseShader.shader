Shader "Unlit/BlockNoiseShader"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

            CGPROGRAM
            #pragma surface surf Standard fullforwardshadows
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

            float block(fixed2 st)
            {
                fixed2 p = floor(st);
                return random(p);
            }

            void surf (Input In,inout SurfaceOutputStandard o)
            {
                float c = block(In.uv_MainTex * 8);
                o.Albedo  = fixed4(c, c, c, 1);
            }
            ENDCG
        }
    }
