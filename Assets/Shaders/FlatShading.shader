Shader "Unlit/FlatShading"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwadBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom

            #include "UnityCG.cginc"

            struct v2g
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
                float3 vertex : TEXCOORD1;
            };

            struct g2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float light : TEXCOORD1;
            };

            float4 _Color;
            sampler2D _MainTex;

            v2g vert (appdata_full v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.pos = UnityObjectToClipPos(o.vertex);
                o.uv = v.texcoord;
                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> triangleStream)
            {
                g2f o;
                float3 vecA = IN[1].vertex - IN[0].vertex;
                float3 vecB = IN[2].vertex - IN[0].vertex;
                float3 normal = cross(vecA, vecB);
                normal = normalize(mul(normal, (float3x3) unity_WorldToObject));

                // compute diffuse light
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                o.light = max(0., dot(normal, lightDir));

                //
                o.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;
                for(int i = 0; i < 3; i++)
                {
                    o.pos = IN[i].pos;
                    triangleStream.Append(o);
                }
            }

            fixed4 frag (g2f i) : C0LOR
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= i.light * _Color;
                return col;
            }
            ENDCG
        }
    }
}
