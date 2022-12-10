Shader "Unlit/CameraPolygon"
{
    Properties
    {
        _FarColor("Far Color", Color) = (1,1,1,1)
        _NearColor("Near Color", Color) = (0,0,0,1)
        _ScaleFactor("Scale Factor", float) = 0.5
        _StartDistance("Start Distance", float) = 3.0
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

            fixed4 _FarColor;
            fixed4 _NearColor;
            float _ScaleFactor;
            float _StartDistance;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };

            struct g2f
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };
            
            appdata vert (appdata v)
            {
                return v;
            }

            float rand(float2 seed) {
                return frac(sin(dot(seed.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            [maxvertexcount(3)]
            void geom (triangle appdata input[3], inout TriangleStream<g2f> stream) {
                // ポリゴンの中心座標
                float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;
                // ワールド座標に変換
                float4 worldPos = mul(unity_ObjectToWorld, float4(center, 1.0));
                // ワールド座標 - カメラの距離を算出。
                float3 dist = length(_WorldSpaceCameraPos - worldPos);

                // 辺ベクトルの計算
                float3 vec1 = input[1].vertex - input[0].vertex;
                float3 vec2 = input[2].vertex - input[0].vertex;
                float3 normal = normalize(cross(vec1, vec2));

                // カメラとの距離に応じてポリゴンを変化させる
                fixed destruction = clamp(_StartDistance - dist, 0.0, 1.0);
                // 色のグラデーション
                fixed gradient = clamp(dist - _StartDistance, 0.0, 1.0);

                // ランダムな値
                fixed random = rand(center.xy);
                fixed3 random3 = random.xxx;

                [unroll]
                for (int i = 0; i < 3; i++) {
                    appdata v = input[i];
                    g2f o;
                    // 法線方向へ移動
                    v.vertex.xyz += normal * destruction * _ScaleFactor * random3;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    // 色を変化
                    o.color = fixed4(lerp(_NearColor.rgb, _FarColor.rgb, gradient), 1);
                    stream.Append(o);
                }
                stream.RestartStrip();
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = i.color;
                return col;
            }
            ENDCG
        }
    }
}
