Shader "Unlit/movePolygon"
{
    Properties
    {
        _Color("Color", Color) = (1, 1,1,1)
        _ScaleFactor("Scale Factor", float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom

            #include "UnityCG.cginc"

            fixed4 _Color;
            float _ScaleFactor;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct g2f
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            appdata vert (appdata v)
            {
                return v;
            }

            [maxvertexcount(3)]
            void geom8(triangle appdata input[3], inout TriangleStream<g2f> stream)
            {
                float3 vec1 = input[1].vertex - input[0].vertex;
                float3 vec2 = input[2].vertex - input[0].vertex;
                float3 normal = normalize(cross(vec1, vec2));

                [unroll]
                for (int i = 0; i < 3; i ++)
                {
                    appdata v = input[i];
                    g2f o;
                    v.vertex.xyz += normal * (_SinTime.w * 0.5 + 0.5) * _ScaleFactor;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    stream.Append(o);
                }
                stream.RestartStrip();
            }
            
            fixed4 frag (g2f i) : SV_Target
            {
                fixed4 col = _Color;
                return col;
            }
            ENDCG
        }
    }
}
