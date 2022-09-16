Shader "Unlit/geogeogeo"
{
    Properties
    {
        _ScaleFactor("ScaleFactor", Range(0, 1.0)) = 0.5
        _PositionFactor("Position Factor", Range(0, 1.0)) = 0.5
        _RotationFactor("Rotation Factor", Range(0, 1.0)) = 0.5
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

            float _PositionFactor;
            float _RotationFactor;
            float _ScaleFactor;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 localPos : TEXCOORD0;
            };

            struct g2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };
            


            appdata vert (appdata v)
            {
                appdata o;
                o.localPos = v.vertex.xyz;
                return v;
            }

            float3 rotate(float3 p, float angle,float3 axis)
            {
                float3 a = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float r = 1.0 - c;
                float3x3 m = float3x3(
                    a.x * a.x * r + c, a.y * a.x * r + a.z * s, a.z * a.x * r - a.y * s,
                    a.x * a.y * r - a.z * s, a.y * a.y * r + c, a.z * a.y * r + a.x * s,
                    a.x * a.z * r + a.y * s, a.y * a.z * r - a.x * s, a.z * a.z * r + c
                );
                return mul(m, p);
            }

            //ランダムな値を返す
            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            [maxvertexcount(3)]
            void geom(triangle appdata input[3], uint pid : SV_PrimitiveID,inout TriangleStream<g2f> stream)
            {
                float3 vec1 = input[1].vertex - input[0].vertex;
                float3 vec2 = input[2].vertex - input[0].vertex;
                float3 normal = normalize(cross(vec1, vec2));

                float3 center = (input[0].vertex + input[1].vertex + input[2].vertex / 3);
                float random = 2.0 * rand(center.xy) - 0.5;
                float3 r3 = random.xxx;

                [unroll]
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;
// center + は中心を起点にしている。
                    v.vertex.xyz = center + rotate(v.vertex.xyz - center, (pid + _Time.y) * _RotationFactor, r3);
                    // 法線ベクトル方向に分解。
                    v.vertex.xyz = center + (v.vertex.xyz - center) * (1.0 - _ScaleFactor);
                    v.vertex.xyz += normal * _PositionFactor * abs(r3);

                    o.vertex = UnityObjectToClipPos(v.vertex);

                    float r = rand(v.localPos.xy);
                    float g = rand(v.localPos.xz);
                    float b = rand(v.localPos.yz);

                    o.color = fixed4(r, g, b, 1);
                    stream.Append(o);
                }
            }
            
            fixed4 frag (g2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}
