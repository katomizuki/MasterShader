Shader "Unlit/PerlinNoise"
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

            sampler2D _MainTex;

            struct Input
            {
               float2 uv_MainTex; 
            };

            fixed2 random2(fixed2 st)
            {
                st = fixed2( dot(st,fixed2(127.1,311.7)),
                           dot(st,fixed2(269.5,183.3)) );
                return -1.0 + 2.0*frac(sin(st)*43758.5453123);
            }

            float perlinNoise(fixed2 st)
            {
                fixed2 p = floor(st);
                fixed2 f = frac(st);
                fixed2 u = f*f*(3.0-2.0*f);

                float v00 = random2(p+fixed2(0,0));
                float v10 = random2(p+fixed2(1,0));
                float v01 = random2(p+fixed2(0,1));
                float v11 = random2(p+fixed2(1,1));

                return lerp( lerp( dot( v00, f - fixed2(0,0) ), dot( v10, f - fixed2(1,0) ), u.x ),
                         lerp( dot( v01, f - fixed2(0,1) ), dot( v11, f - fixed2(1,1) ), u.x ), 
                         u.y)+0.5f;
            }

            void surf (Input In, inout SurfaceOutputStandard o)
            {
                float c = perlinNoise(In.uv_MainTex*8);//(perlinNoise( IN.uv_MainTex*6))*0.5+0.5;        
                o.Albedo = fixed4(c,c,c,1);
                o.Metallic = 0;
                o.Smoothness = 0;
                o.Alpha = 1;
            }
            ENDCG
        }
    }