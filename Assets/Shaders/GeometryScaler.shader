Shader "Unlit/GeometryScaler"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _ScaleFactor("Scale Factor",Range(0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"
            fixed4 _Color;
            float _ScaleFactor;
            

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            struct g2f 
            {
                float4 vertex : SV_POSITION;
            };

            [maxvertexcount(3)]
            void geom(triangle appdata input[3], inout TriangleStream<g2f> stream)
            {
                // 一枚のポリゴンの中心 全ての頂点を足して3でわる
                float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;
                
                [unroll]// 繰り返す処理をたたみ込んで最適化している
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;
                    // 中心を起点にスケールを変える
                    // センターを引いてあげる　c　の方
                    // cv * (1.0 - _ScaleFactor) => cv中心からcv
                    // 
                    v.vertex.xyz = (v.vertex.xyz - center) * (1.0 - _ScaleFactor) + center;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    stream.Append(i);
                }
            }

            // フラグメントシェーダー
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                return _Color;
            }
            ENDCG
        }
    }
}
