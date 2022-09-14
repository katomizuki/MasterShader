Shader "Unlit/GeometryColor"
{
  SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            appdata vert(appdata v)
            {
                return v;
            }

            struct g2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };

            //ランダムな値を返す
            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            // ジオメトリシェーダー
            [maxvertexcount(3)]
            void geom(triangle appdata input[3],inout TriangleStream<g2f> stream)
            {
                //1枚のポリゴンの中心
                float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;
		//ランダムな値
                float r = rand(center.xy);
                float g = rand(center.xz);
                float b = rand(center.yz);

                [unroll]
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.color = fixed4(r,g,b,1);
                    stream.Append(o);
                }
            }

            fixed4 frag(g2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    } 
}
