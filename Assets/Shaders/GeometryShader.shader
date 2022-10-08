Shader "Unlit/GeometryShader"
{
    Properties
    {
        Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom

            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct g2f
            {
                float4 vertex : SV_POSITION;
            };


            appdata vert (appdata v)
            {
                return v;
            }

            float4 _Color;

            [maxvertexcount(3)]
            void geom(triangle appdata input[3], inout LineStream<g2f> stream)
            {
                [unroll]
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    stream.Append(o);
                }
            }
            fixed4 frag (g2f i) : SV_Target
            {
                return  _Color;
            }
            ENDCG
        }
    }
}
